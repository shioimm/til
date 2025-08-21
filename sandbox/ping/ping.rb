require "socket"

ECHO_HEADER_SIZE = 8

class Ping
  class ICMPPacket
    TYPE = { request: 8, reply: 0 }

    def initialize(type, seq)
      @type = TYPE(type)
      @code = 0
      @id = Process.pid & 0xffff
      @seq = seq
    end

    def message
      # WIP
    end

    private

    def calc_checksum
      # WIP
    end
  end

  def self.execute!(dest)
    new(dest).execute!
  end

  def initialize(dest)
    @size = 64
    @count = 5
    @timeout = 1
    @total_time = 0
    @total_count = 0

    @sock = Socket.new(Socket::AF_INET, Socket::SOCK_RAW, Socket::IPPROTO_ICMP)
    @addr = Socket.sockaddr_in(0, dest)
  end

  def execute!
    @count.times.each.with_index(1) do |seq|
      sent_at = send_echo(seq)
      receive_reply(sent_at)
      @total_time += 1 # WIP
      @total_count += 1 # WIP

      sleep 1
    end

    puts "RTT (Avg): #{@total_time / @total_count}ms"
  end

  private

  def send_request(seq)
    # WIP
    echo_message = ICMPPacket.new(:request, seq).message
    @sock.send(echo_message, 0, @addr)
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  def receive_reply(sent_at)
    # WIP
  end
end

dest = ARGV.first

begin
  raise "Missing ping target" if dest.nil?

  Ping.execute!(dest)
rescue => e
  puts e.full_message
end
