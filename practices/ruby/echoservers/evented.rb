require 'socket'

class Evented
  DATA_SIZE = 16 * 1024

  class Connection
    attr_accessor :sock

    def initialize(sock)
      @sock = sock
      @response = ''
      @request = ''

      on_writable
    end

    def on_writable
      bytes = sock.write_nonblock(@response)
      @response.slice(0, bytes)
    end

    def on_data(msg)
      @request << msg

      if @request.end_with?("\r\n")
        @response << @request + "\r\n"
        on_writable
        @request = ''
      end
    end

    def reading?
      true
    end

    def writing?
      !(@response.empty?)
    end
  end

  def initialize(host, port)
    @listener = TCPServer.open(host, port)
    @handles = {}

    _protocol, port, host, _ipaddr = @listener.addr
    puts "Server is running on #{host}:#{port}"

    trap(:INT) do
      puts "Shutdown on #{Time.now.strftime("%Y/%m/%d %H:%M")}"
      exit
    end
  end

  def run
    loop do
      reading_socks = @handles.values.select(&:reading?).map(&:sock)
      writing_socks = @handles.values.select(&:writing?).map(&:sock)

      readables, writables = IO.select(reading_socks + [listener], writing_socks)

      readables.each do |rsock|
        if rsock == @listener
          sock = @listener.accept
          @handles[rsock.fileno] = Connection.new(sock)
        else
          conn = @handles[rsock.fileno]

          begin
            msg = rsock.read_nonblock(DATA_SIZE)
            conn.on_data(msg)
          rescue Errno::EAGAIN
          rescue EOFError
            @handle.delete(rsock.fileno)
          end
        end
      end

      writables.each do |wsock|
        conn = @handles[wsock.fileno]
        conn.on_writable
      end
    end
  end

  private attr_reader :listener
end

HOST = 'localhost'
PORT = 12345

server = Evented.new(HOST, PORT)
server.run
