require 'socket'

class ThreadBasedWithQueue
  DATA_SIZE  = 16 * 1024
  CONCURRECY = 4

  def initialize(host, port)
    @listener = TCPServer.open(host, port)
    @workers  = ThreadGroup.new
    @queue    = SizedQueue.new(CONCURRECY)

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
      workers.add spawn_thread
    end

    loop do
      queue.enq ->(conn) { server_processing_with conn }
    end

    workers.list.each(&:join)
  end

  private
    attr_reader :listener, :workers, :queue

    def spawn_thread
      Thread.new do
        while req = queue.deq
          req.call listener.accept
        end
      end
    end

    def server_processing_with(conn)
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

HOST = 'localhost'
PORT = 12345

server = ThreadBasedWithQueue.new(HOST, PORT)
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
# Time taken for tests:   3.071 seconds
# Complete requests:      1000
# Failed requests:        0
# Non-2xx responses:      1000
# Total transferred:      123000 bytes
# HTML transferred:       0 bytes
# Requests per second:    325.58 [#/sec] (mean)
# Time per request:       30.715 [ms] (mean)
# Time per request:       3.071 [ms] (mean, across all concurrent requests)
# Transfer rate:          39.11 [Kbytes/sec] received
#
# Connection Times (ms)
#               min  mean[+/-sd] median   max
# Connect:        0    0   0.2      0       2
# Processing:    11   30   5.9     30      41
# Waiting:       11   30   5.9     29      41
# Total:         11   30   5.8     30      41
#
# Percentage of the requests served within a certain time (ms)
#   50%     30
#   66%     35
#   75%     36
#   80%     36
#   90%     38
#   95%     39
#   98%     39
#   99%     40
#  100%     41 (longest request)
