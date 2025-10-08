require "net-http2"

HOST = "https://example.com"

ctx = OpenSSL::SSL::SSLContext.new
ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE # 証明書の検証を無効化
ctx.alpn_protocols = ["h2"]

client = NetHttp2::Client.new(HOST, ssl_context: ctx)

begin
  response = client.call(:get, "/")

  puts "--- HEADER ---"
  response.headers.each { |k, v| puts "#{k}: #{v}" }

  puts "--- BODY ---"
  puts response.body
ensure
  begin
    client.close
  rescue EOFError, SocketError
  end
end
