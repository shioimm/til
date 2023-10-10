require 'socket'

class ProcessBased
  DATA_SIZE  = 16 * 1024
  CONCURRECY = 4

  def initialize(host, port)
    @listener = TCPServer.open(host, port)
    @workers  = []

    _protocol, port, host, _ipaddr = @listener.addr
    puts "Server is running on #{host}:#{port}"

    trap(:INT) { exit }
  end

  def run
    CONCURRECY.times do
      workers << fork { server_processing }
    end

    trap(:INT) do
      kill_processes(:INT)
      puts "Shutdown on #{Time.now.strftime("%Y/%m/%d %H:%M")}"
      exit
    end

    clean_up_terminated_processes
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

    def kill_processes(signal)
      workers.each do |worker|
        begin
          Process.kill(signal, worker)
        rescue Errno::ESRCH
        end
      end
    end

    def clean_up_terminated_processes
      loop do
        worker = Process.wait
        puts "Process #{worker} quit unexpectedly"

        workers.delete worker
        workers << spawn_process
      end
    end
end

HOST = 'localhost'
PORT = 12345

server = ProcessBased.new(HOST, PORT)
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
# Time taken for tests:   2.733 seconds
# Complete requests:      1000
# Failed requests:        0
# Non-2xx responses:      1000
# Total transferred:      123000 bytes
# HTML transferred:       0 bytes
# Requests per second:    365.84 [#/sec] (mean)
# Time per request:       27.334 [ms] (mean)
# Time per request:       2.733 [ms] (mean, across all concurrent requests)
# Transfer rate:          43.94 [Kbytes/sec] received
#
# Connection Times (ms)
#               min  mean[+/-sd] median   max
# Connect:        0    0   0.2      0       3
# Processing:    11   27   5.1     27      39
# Waiting:       11   27   5.1     27      39
# Total:         11   27   5.0     27      39
#
# Percentage of the requests served within a certain time (ms)
#   50%     27
#   66%     32
#   75%     32
#   80%     32
#   90%     33
#   95%     33
#   98%     34
#   99%     34
#  100%     39 (longest request)
