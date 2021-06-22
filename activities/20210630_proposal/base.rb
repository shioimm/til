# Ref: https://github.com/igrigorik/http-2/blob/master/example/client.rb

require 'socket'
require 'openssl'
require 'uri'

H2 = 'h2'.freeze

uri = URI.parse(ARGV[0])
tcp = TCPSocket.new(uri.host, uri.port)
ctx = OpenSSL::SSL::SSLContext.new

ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
ctx.alpn_protocols = [H2]

sock = OpenSSL::SSL::SSLSocket.new(tcp, ctx)
sock.sync_close = true
sock.hostname = uri.hostname
sock.connect

while !sock.closed? && !sock.eof?
  data = sock.read_nonblock(1024)

  begin
    p data
  rescue StandardError => e
    puts "#{e.class} exception: #{e.message} - closing socket."
    e.backtrace.each { |l| puts "\t" + l }
  ensure
    sock.close
  end
end
