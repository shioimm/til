require 'socket'

class RactorBased
  DATA_SIZE = 16 * 1024

  def initialize(host, port)
    @listener = TCPServer.open(host, port)

    _protocol, port, host, _ipaddr = @listener.addr
    puts "Server is running on #{host}:#{port}"

    trap(:INT) do
      puts "Shutdown on #{Time.now.strftime("%Y/%m/%d %H:%M")}"
      exit
    end
  end

  def run
    loop do
      Ractor.new {
        begin
          conn = Ractor.recv

          msg = conn.readpartial(DATA_SIZE)

          puts "Client requests: #{msg.split("\r\n").first}"

          sleep 0.01

          conn.puts '-- Server received the request message --'
          conn.puts "\r\n"
          conn.puts msg
          conn.close
        rescue EOFError
        end
      }.send(listener.accept, move: true).take
    end
  end

  private attr_reader :listener
end

HOST = 'localhost'
PORT = 12345

server = RactorBased.new(HOST, PORT)
server.run

# $ ab -n 1000 -c 10 'http://[::1]:12345/'
#
# Server Software:
# Server Hostname:        ::1
# Server Port:            12345
#
# Document Path:          /
# Document Length:        0 bytes
#
# Concurrency Level:      10
# Time taken for tests:   11.927 seconds
# Complete requests:      1000
# Failed requests:        0
# Non-2xx responses:      1000
# Total transferred:      123000 bytes
# HTML transferred:       0 bytes
# Requests per second:    83.85 [#/sec] (mean)
# Time per request:       119.265 [ms] (mean)
# Time per request:       11.927 [ms] (mean, across all concurrent requests)
# Transfer rate:          10.07 [Kbytes/sec] received
#
# Connection Times (ms)
#               min  mean[+/-sd] median   max
# Connect:        0    0   0.1      0       1
# Processing:    11  118   7.9    119     127
# Waiting:       11  118   7.9    119     127
# Total:         11  119   7.9    119     128
#
# Percentage of the requests served within a certain time (ms)
#   50%    119
#   66%    120
#   75%    121
#   80%    122
#   90%    123
#   95%    124
#   98%    125
#   99%    125
#  100%    128 (longest request)
