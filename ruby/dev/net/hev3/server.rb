require "puma"
require "puma/configuration"
require "socket"
require "openssl"
require "http/2"

# $ openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365 -nodes -subj "/CN=localhost"
# $ ruby server.rb cert.pem key.pem
# $ curl --http2 -k -v https://localhost:8443/
abort "Usage: ruby #{$PROGRAM_NAME} CERT KEY" unless ARGV.size == 2

ctx = OpenSSL::SSL::SSLContext.new

ctx.cert = OpenSSL::X509::Certificate.new(File.read(ARGV[0]))
ctx.key = OpenSSL::PKey.read(File.read(ARGV[1]))
ctx.min_version = OpenSSL::SSL::TLS1_2_VERSION

ctx.alpn_select_cb = lambda { |protocols|
  ["h2", "http/1.1"].find { protocols.include?(it) } ||
    raise(OpenSSL::SSL::SSLError, "No supported ALPN protocol")
}

def respond_by_http2(socket)
  connection = HTTP2::Server.new

  connection.on(:frame) { |bytes| socket.write(bytes) }

  connection.on(:stream) do |stream|
    stream.on(:half_close) do
      puts "HTTP/2 stream=#{stream.id}"
      stream.headers({ ":status" => "200", "content-type" => "text/plain" })
      stream.data("Hello!\n", end_stream: true)
    end
  end

  loop { connection << socket.readpartial(16_384) }
end

# HTTPS fallback for the mock's HTTP/1.1 GET requests.
def respond_by_http1(socket)
  while (line = socket.gets)
    break if line == "\r\n"
  end

  return unless line

  socket.write("HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 7\r\nConnection: close\r\n\r\nHello!\n")
end

https_port = Integer(ENV.fetch("HTTPS_PORT", "8443"))
listeners = ["127.0.0.1", "::1"].map { TCPServer.new(it, https_port) }

listeners.each do |listener|
  Thread.new do
    loop do
      Thread.new(listener.accept) do |tcp_socket|
        ssl_socket = nil
        begin
          ssl_socket = OpenSSL::SSL::SSLSocket.new(tcp_socket, ctx)
          ssl_socket.sync_close = true
          ssl_socket.accept

          protocol = ssl_socket.alpn_protocol || "http/1.1"
          puts "HTTPS peer=#{tcp_socket.peeraddr[3]} ALPN=#{protocol}"
          protocol == "h2" ? respond_by_http2(ssl_socket) : respond_by_http1(ssl_socket)

        rescue EOFError, Errno::ECONNRESET, Errno::EPIPE
          # Clients may close losing connections during a connection race.
        rescue OpenSSL::SSL::SSLError, HTTP2::Error::Error => e
          warn "HTTPS: #{e.class}: #{e.message}"
        ensure
          ssl_socket&.close
          tcp_socket.close unless tcp_socket.closed?
        end
      end
    end
  end
end

app = Proc.new { |env|
  [200, { "content-type" => "text/plain" }, ["Hello!\n"]]
}

config = Puma::Configuration.new do |conf|
  conf.port Integer(ENV.fetch("HTTP_PORT", "8080")), "localhost"

  conf.app app
end

Puma::Launcher.new(config).run
