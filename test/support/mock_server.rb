# frozen_string_literal: true

require "socket"
require "json"

# In-process HTTP mock. The handler receives (path, parsed_body, headers) and
# returns [status, payload]. Records every request for assertions.
class MockServer
  attr_reader :requests

  def initialize(&handler)
    @handler = handler
    @requests = []
    @server = TCPServer.new("127.0.0.1", 0)
    @port = @server.addr[1]
    @thread = Thread.new { serve }
  end

  def base_url
    "http://127.0.0.1:#{@port}"
  end

  def stop
    @server.close
  rescue StandardError
    nil
  ensure
    @thread&.kill
  end

  private

  def serve
    loop do
      client = @server.accept
      Thread.new(client) { |c| handle(c) }
    end
  rescue StandardError
    nil
  end

  def handle(client)
    request_line = client.gets
    return unless request_line

    method, path, = request_line.split
    headers = {}
    while (line = client.gets) && line != "\r\n"
      key, value = line.split(":", 2)
      headers[key.downcase.strip] = value.strip if value
    end
    length = headers["content-length"].to_i
    raw = length.positive? ? client.read(length) : ""
    body = begin
      JSON.parse(raw)
    rescue JSON::ParserError
      {}
    end

    @requests << { method: method, path: path, headers: headers, body: body }
    status, payload = @handler.call(path, body, headers)
    json = payload.is_a?(String) ? payload : JSON.generate(payload)

    client.write "HTTP/1.1 #{status} OK\r\n"
    client.write "content-type: application/json\r\n"
    client.write "content-length: #{json.bytesize}\r\n"
    client.write "connection: close\r\n\r\n"
    client.write json
  rescue StandardError
    nil
  ensure
    begin
      client.close
    rescue StandardError
      nil
    end
  end
end
