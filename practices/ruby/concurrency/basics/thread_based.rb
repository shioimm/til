require 'socket'

class ThreadBased
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
    Thread.abort_on_exception = true

    loop do
      Thread.new(listener.accept) do |conn|
        begin
          msg = conn.readpartial(DATA_SIZE)

          puts "Client requests: #{msg.split("\r\n").first}"

          sleep 0.01

          conn.puts '-- Server received the request message --'
          conn.puts "\r\n"
          conn.puts msg
          conn.close
        rescue EOFError
        end
      end
    end
  end

  private attr_reader :listener
end

HOST = 'localhost'
PORT = 12345

server = ThreadBased.new(HOST, PORT)
server.run

# -- Benchmark --
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
# Time taken for tests:   1.267 seconds
# Complete requests:      1000
# Failed requests:        0
# Non-2xx responses:      1000
# Total transferred:      123000 bytes
# HTML transferred:       0 bytes
# Requests per second:    789.55 [#/sec] (mean)
# Time per request:       12.665 [ms] (mean)
# Time per request:       1.267 [ms] (mean, across all concurrent requests)
# Transfer rate:          94.84 [Kbytes/sec] received
#
# Connection Times (ms)
#               min  mean[+/-sd] median   max
# Connect:        0    0   0.2      0       2
# Processing:    10   12   1.1     12      15
# Waiting:       10   12   0.9     12      14
# Total:         10   12   1.1     12      16
#
# Percentage of the requests served within a certain time (ms)
#   50%     12
#   66%     13
#   75%     13
#   80%     13
#   90%     14
#   95%     15
#   98%     15
#   99%     15
#  100%     16 (longest request)
