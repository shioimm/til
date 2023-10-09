require 'socket'

class Serial
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

      msg = conn.readpartial(DATA_SIZE)

      puts "Client requests: #{msg.split("\r\n").first}"

      sleep 0.01

      conn.puts '-- Server received the request message --'
      conn.puts "\r\n"
      conn.puts msg
      conn.close
    end
  end

  private attr_reader :listener
end

HOST = 'localhost'
PORT = 12345

server = Serial.new(HOST, PORT)
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
# Time taken for tests:   11.445 seconds
# Complete requests:      1000
# Failed requests:        0
# Non-2xx responses:      1000
# Total transferred:      123000 bytes
# HTML transferred:       0 bytes
# Requests per second:    87.37 [#/sec] (mean)
# Time per request:       114.450 [ms] (mean)
# Time per request:       11.445 [ms] (mean, across all concurrent requests)
# Transfer rate:          10.50 [Kbytes/sec] received
#
# Connection Times (ms)
#               min  mean[+/-sd] median   max
# Connect:        0    0   0.1      0       1
# Processing:    12  113   7.6    114     123
# Waiting:       12  113   7.6    114     123
# Total:         12  114   7.6    114     123
#
# Percentage of the requests served within a certain time (ms)
#   50%    114
#   66%    116
#   75%    117
#   80%    117
#   90%    118
#   95%    120
#   98%    121
#   99%    121
#  100%    123 (longest request)
