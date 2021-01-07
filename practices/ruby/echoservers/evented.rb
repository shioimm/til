require 'socket'

class Evented
  DATA_SIZE = 16 * 1024

  class Connection
    attr_accessor :sock

    def initialize(sock)
      @sock = sock
      @res = ''
      @req = ''
    end

    def on_writable
      written_size = sock.write_nonblock(@res)
      res.slice!(0, written_size)
    end

    def ready_to_respond(msg)
      req.concat(msg)
      res.concat(req + "\r\n")
      req.clear
    end

    def to_read?
      true
    end

    def to_write?
      !(res.empty?)
    end

    private attr_reader :req, :res
  end

  def initialize(host, port)
    @listener = TCPServer.open(host, port)
    @connections = {}

    _protocol, port, host, _ipaddr = @listener.addr
    puts "Server is running on #{host}:#{port}"

    trap(:INT) do
      puts "Shutdown on #{Time.now.strftime("%Y/%m/%d %H:%M")}"
      exit
    end
  end

  def run
    loop do
      socks_to_read = @connections.values.select(&:to_read?).map(&:sock)
      socks_to_write = @connections.values.select(&:to_write?).map(&:sock)

      readables, writables = IO.select([listener, *socks_to_read], socks_to_write)

      readables.each do |rsock|
        if rsock == listener
          client = listener.accept
          @connections[client.fileno] = Connection.new(client)
        else
          conn = @connections[rsock.fileno]

          begin
            msg = rsock.read_nonblock(DATA_SIZE)
            conn.ready_to_respond(msg)

            puts "Client requests: #{msg.split("\r\n").first}"

            sleep 0.01

            writables << conn.sock
          rescue Errno::EAGAIN
          rescue EOFError
            @connections.delete(rsock.fileno)
          end
        end
      end

      writables.each do |wsock|
        conn = @connections[wsock.fileno]
        conn.on_writable

        unless conn.to_write?
          @connections.delete(wsock.fileno)
          conn.sock.close
        end
      end
    end
  end

  private attr_reader :listener
end

HOST = 'localhost'
PORT = 12345

server = Evented.new(HOST, PORT)
server.run

# $ ab -n 1000 -c 10 'http://[::1]:12345/'
#
# Server Software:
# Server Hostname:        ::1
# Server Port:            12345
#
# Document Path:          /
# Document Length:        2 bytes
#
# Concurrency Level:      10
# Time taken for tests:   11.502 seconds
# Complete requests:      1000
# Failed requests:        0
# Non-2xx responses:      1000
# Total transferred:      81000 bytes
# HTML transferred:       2000 bytes
# Requests per second:    86.94 [#/sec] (mean)
# Time per request:       115.019 [ms] (mean)
# Time per request:       11.502 [ms] (mean, across all concurrent requests)
# Transfer rate:          6.88 [Kbytes/sec] received
#
# Connection Times (ms)
#               min  mean[+/-sd] median   max
# Connect:        0    0   0.1      0       1
# Processing:    11  114   6.9    114     128
# Waiting:       10  114   6.9    114     128
# Total:         11  114   6.9    115     128
#
# Percentage of the requests served within a certain time (ms)
#   50%    115
#   66%    116
#   75%    117
#   80%    117
#   90%    119
#   95%    121
#   98%    123
#   99%    123
#  100%    128 (longest request)#
