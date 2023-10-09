require 'socket'

class FiberBased
  DATA_SIZE  = 16 * 1024
  CONCURRECY = 4

  def initialize(host, port)
    @listener = TCPServer.open(host, port)
    @workers  = []

    _protocol, port, host, _ipaddr = @listener.addr
    puts "Server is running on #{host}:#{port}"

    trap(:INT) do
      puts "Shutdown on #{Time.now.strftime("%Y/%m/%d %H:%M")}"
      exit
    end
  end

  def run
    CONCURRECY.times do
      workers << Fiber.new { server_processing }
    end

    workers.each(&:resume)
  end

  private
    attr_reader   :listener
    attr_accessor :workers

    def server_processing
      loop do
        conn = listener.accept

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

HOST = 'localhost'
PORT = 12345

server = FiberBased.new(HOST, PORT)
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
# Time taken for tests:   11.368 seconds
# Complete requests:      1000
# Failed requests:        0
# Non-2xx responses:      1000
# Total transferred:      123000 bytes
# HTML transferred:       0 bytes
# Requests per second:    87.97 [#/sec] (mean)
# Time per request:       113.676 [ms] (mean)
# Time per request:       11.368 [ms] (mean, across all concurrent requests)
# Transfer rate:          10.57 [Kbytes/sec] received
#
# Connection Times (ms)
#               min  mean[+/-sd] median   max
# Connect:        0    0   0.1      0       1
# Processing:    11  113   7.5    113     123
# Waiting:       10  113   7.5    113     123
# Total:         11  113   7.5    113     123
#
# Percentage of the requests served within a certain time (ms)
#   50%    113
#   66%    115
#   75%    116
#   80%    117
#   90%    118
#   95%    119
#   98%    120
#   99%    121
#  100%    123 (longest request)
