require 'socket'

class RactorBased
  DATA_SIZE  = 16 * 1024
  CONCURRECY = 4

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
    CONCURRECY.times do
      Ractor.new(pipe) do |pipe|
        loop do
          conn = pipe.take

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

    loop do
      conn = listener.accept
      pipe.send(conn, move: true)
    end
  end

  private
    attr_reader :listener

    def pipe
      @pipe ||= Ractor.new do
        loop do
          conn = Ractor.recv
          Ractor.yield(conn, move: true)
        end
      end
    end
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
# Time taken for tests:   2.837 seconds
# Complete requests:      1000
# Failed requests:        0
# Non-2xx responses:      1000
# Total transferred:      123000 bytes
# HTML transferred:       0 bytes
# Requests per second:    352.53 [#/sec] (mean)
# Time per request:       28.366 [ms] (mean)
# Time per request:       2.837 [ms] (mean, across all concurrent requests)
# Transfer rate:          42.34 [Kbytes/sec] received
#
# Connection Times (ms)
#               min  mean[+/-sd] median   max
# Connect:        0    0   0.2      0       1
# Processing:    11   28   5.2     28      38
# Waiting:       11   28   5.2     28      38
# Total:         11   28   5.1     28      38
#
# Percentage of the requests served within a certain time (ms)
#   50%     28
#   66%     32
#   75%     32
#   80%     33
#   90%     35
#   95%     35
#   98%     36
#   99%     37
#  100%     38 (longest request)
