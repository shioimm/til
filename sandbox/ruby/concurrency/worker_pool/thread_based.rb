require 'socket'

class ThreadBased
  DATA_SIZE  = 16 * 1024
  CONCURRECY = 4

  def initialize(host, port)
    @listener = TCPServer.open(host, port)
    @workers  = ThreadGroup.new

    _protocol, port, host, _ipaddr = @listener.addr
    puts "Server is running on #{host}:#{port}"

    Thread.abort_on_exception = true

    trap(:INT) do
      puts "Shutdown on #{Time.now.strftime("%Y/%m/%d %H:%M")}"
      exit
    end
  end

  def run
    CONCURRECY.times do
      workers.add Thread.new { server_processing }
    end

    workers.list.each(&:join)
  end

  private
    attr_reader :listener, :workers

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

server = ThreadBased.new(HOST, PORT)
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
# Time taken for tests:   2.951 seconds
# Complete requests:      1000
# Failed requests:        0
# Non-2xx responses:      1000
# Total transferred:      123000 bytes
# HTML transferred:       0 bytes
# Requests per second:    338.83 [#/sec] (mean)
# Time per request:       29.514 [ms] (mean)
# Time per request:       2.951 [ms] (mean, across all concurrent requests)
# Transfer rate:          40.70 [Kbytes/sec] received
#
# Connection Times (ms)
#               min  mean[+/-sd] median   max
# Connect:        0    0   0.2      0       1
# Processing:    13   29   5.0     29      40
# Waiting:       12   29   5.0     28      39
# Total:         13   29   4.9     29      40
#
# Percentage of the requests served within a certain time (ms)
#   50%     29
#   66%     32
#   75%     34
#   80%     34
#   90%     36
#   95%     37
#   98%     38
#   99%     38
#  100%     40 (longest request)
