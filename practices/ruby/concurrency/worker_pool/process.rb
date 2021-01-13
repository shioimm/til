require 'socket'

class Process
  DATA_SIZE = 16 * 1024
  CONCURRECY = 4

  def initialize(host, port)
    @listener = TCPServer.open(host, port)
    @childs_pids = []

    _protocol, port, host, _ipaddr = @listener.addr
    puts "Server is running on #{host}:#{port}"

    trap(:INT) do
      puts "Shutdown on #{Time.now.strftime("%Y/%m/%d %H:%M")}"
      exit
    end
  end

  def run
    CONCURRECY.times do
      childs_pid << spawn_child
    end

    loop do
      pid = Process.wait
      puts "Process #{pid} quit unexpectedly"

      childs_pids.delete pid
      childs_pids << spawn_child
    end
  end

  private attr_reader :listener, :childs_pids

    def spawn_child
      fork do
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
            break
          rescue EOFError
          end
        end
      end
    end
end
