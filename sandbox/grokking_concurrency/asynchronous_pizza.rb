require "socket"
require "io/nonblock"

class Future
  attr_accessor :coroutine
end

class EventLoop
  def initialize
    @task_count = 0
    @ready = []
    @read_waiting = {}
    @write_waiting = {}
  end

  def add_coroutine(task)
    @ready << [task, nil]
    @task_count += 1
  end

  def add_ready(task, msg = nil)
    @ready << [task, msg]
  end

  def register_read_event(io, future, task)
    @read_waiting[io] = [future, task]
  end

  def register_write_event(io, future, task)
    @write_waiting[io] = [future, task]
  end

  def run
    while @task_count > 0
      if @ready.empty?
        readers, writers = IO.select(@read_waiting.keys, @write_waiting.keys)

        Array(readers).each do |io|
          future, task = @read_waiting.delete(io)
          future.coroutine.call(self, task)
        end

        Array(writers).each do |io|
          future, task = @write_waiting.delete(io)
          future.coroutine.call(self, task)
        end
      end

      task, msg = @ready.shift
      run_coroutine(task, msg)
    end
  end

  private

  def run_coroutine(task, msg)
    future = task.resume(msg)

    if task.alive?
      future.coroutine.call(self, task)
    else
      @task_count -= 1
    end
  end
end

class AsyncSocket
  def initialize(socket)
    @socket = socket
    @socket.nonblock = true
  end

  def accept
    future = Future.new

    future.coroutine = (
      lambda { |event, task|
        begin
          conn = @socket.accept_nonblock
          event.add_ready(task, [conn, conn.peeraddr])
        rescue IO::WaitReadable
          event.register_read_event(@socket, future, task)
        end
      }
    )

    future
  end

  def recv(size)
    future = Future.new

    future.coroutine = (
      lambda { |event, task|
        begin
          data = @socket.recv_nonblock(size)
          event.add_ready(task, data)
        rescue IO::WaitReadable
          event.register_read_event(@socket, future, task)
        rescue EOFError
          event.add_ready(task, "")
        end
      }
    )

    future
  end

  def send(data)
    future = Future.new

    future.coroutine = (
      lambda { |event, task|
        begin
          sent = @socket.write_nonblock(data)
          event.add_ready(task, sent)
        rescue IO::WaitWritable
          event.register_write_event(@socket, future, task)
        end
      }
    )

    future
  end

  def peer_name
    @socket.peeraddr.inspect
  end

  def close
    @socket.close
  end
end

BUFFER_SIZE = 1024
ADDRESS = "127.0.0.1"
PORT = 12345

class Server
  def initialize(event)
    @event = event
    puts "Starting up on: #{ADDRESS}:#{PORT}"
    socket = TCPServer.new(ADDRESS, PORT)
    @server_socket = AsyncSocket.new(socket)
  end

  def start
    Fiber.new do
      puts "Server is listening for incoming connection"

      loop do
        conn, address = Fiber.yield(@server_socket.accept)
        puts "Connected to #{address.inspect}"

        asock = AsyncSocket.new(conn)
        @event.add_coroutine(serve(asock))
      end
    rescue Interrupt
      @server_socket.close
      puts "\nServer stopped."
    end
  end

  def serve(conn)
    Fiber.new do
      loop do
        data = Fiber.yield(conn.recv(BUFFER_SIZE))
        break if data.nil? || data.empty?

        response = begin
                     "Thank you for ordering #{Integer(data)} pizzas!\n"
                   rescue ArgumentError
                     "Wrong number of pizzas, please try again\n"
                   end

        puts "Sending message to #{conn.peer_name}"
        Fiber.yield(conn.send(response))
      end

      puts "Connection with #{conn.peer_name} has been closed"
      conn.close
    end
  end
end

event = EventLoop.new
server = Server.new(event)
event.add_coroutine(server.start)
event.run
