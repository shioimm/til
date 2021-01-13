require 'socket'

class ProcessBased
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
      conn = listener.accept

      pid = fork do
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

      conn.close
      Process.detach pid
    end
  end

  private attr_reader :listener
end

HOST = 'localhost'
PORT = 12345

server = ProcessBased.new(HOST, PORT)
server.run

# -- Benchmark --
# $ab -n 1000 -c 10 'http://[::1]:12345/'
#
#
# Server Software:
# Server Hostname:        ::1
# Server Port:            12345
#
# Document Path:          /
# Document Length:        0 bytes
#
# Concurrency Level:      10
# Time taken for tests:   2.323 seconds
# Complete requests:      1000
# Failed requests:        0
# Non-2xx responses:      1000
# Total transferred:      123000 bytes
# HTML transferred:       0 bytes
# Requests per second:    430.52 [#/sec] (mean)
# Time per request:       23.228 [ms] (mean)
# Time per request:       2.323 [ms] (mean, across all concurrent requests)
# Transfer rate:          51.71 [Kbytes/sec] received
#
# Connection Times (ms)
#               min  mean[+/-sd] median   max
# Connect:        0    1   1.1      0      12
# Processing:    12   22   6.7     22      51
# Waiting:       12   22   6.7     22      50
# Total:         12   23   6.9     23      51
#
# Percentage of the requests served within a certain time (ms)
#   50%     23
#   66%     26
#   75%     28
#   80%     29
#   90%     31
#   95%     35
#   98%     37
#   99%     41
#  100%     51 (longest request)
