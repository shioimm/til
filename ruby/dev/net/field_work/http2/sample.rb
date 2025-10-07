require "socket"
require "openssl"
require "http/2"

HOST = "example.com"
PORT = 443

tcp = TCPSocket.new(HOST, PORT)

ctx = OpenSSL::SSL::SSLContext.new
ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
ctx.alpn_protocols = ["h2"]

tls = OpenSSL::SSL::SSLSocket.new(tcp, ctx)
tls.sync_close = true
tls.hostname = HOST
tls.connect

if tls.alpn_protocol != "h2"
  abort("ALPN failed (negotiated: #{tls.alpn_protocol.inspect})")
end

conn = HTTP2::Client.new
stream = conn.new_stream
body = ""
finished = false

conn.on(:frame) do
  tls.write it
  tls.flush
end

stream.on(:headers) do |headers|
  puts "--- HEADER ---"
  headers.each do |k, v|
    puts "#{k}: #{v}"
  end
end

stream.on(:data) do
  body << it
end

stream.on(:close) do
  finished = true
end

headers = {
  ":method"    => "GET",
  ":scheme"    => "https",
  ":authority" => "#{HOST}:#{PORT}",
  ":path"      => "/",
  "accept"     => "*/*",
}

stream.headers(headers, end_stream: true)

begin
  until finished
    r, = IO.select([tls], nil, nil, 30)

    next if r.nil?

    data = tls.readpartial(16 * 1024)
    conn << data
  end
rescue EOFError
ensure
  puts "--- BODY ---"
  puts body
  tls.close
end
