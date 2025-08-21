require "socket"

class Ping
  class ICMPRequestPacket
    TYPE = 8
    CODE = 0
    PAYLOAD_SIZE = 48
    WORD_MASK = 0xFFFF
    PAD_OCTET = "\x00".b

    def initialize(seq, sends_at)
      @id = Process.pid & WORD_MASK
      @seq = seq & WORD_MASK
      @sends_at = sends_at
    end

    def message
      header = [TYPE, CODE, 0, @id, @seq].pack("C C n n n")
      checksum = calc_checksum(header + payload)
      header = [TYPE, CODE, checksum, @id, @seq].pack("C C n n n")
      header + payload
    end

    private

    def payload
      @payload ||= (
        timestamp = [@sends_at.to_i, @sends_at.usec].pack("N N")
        pad = PAD_OCTET * (PAYLOAD_SIZE - timestamp.bytesize)
        timestamp + pad
      )
    end

    def calc_checksum(bin)
      sum = 0

      bin.bytes.each_slice(2) do |hi, lo|
        higher = hi || 0
        lower = lo || 0
        word = (higher << 8) + lower

        sum += word

        lower_16bit = sum & WORD_MASK
        carry = sum >> 16
        sum = lower_16bit + carry # 16bitを超えた分を折り返す
      end

      (~sum) & WORD_MASK # 1の補数を返す
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
      sends_at = Time.now
      send_request!(seq, sends_at)
      receive_reply!(sends_at)
      @total_time += 1 # WIP
      @total_count += 1 # WIP

      sleep 1
    end

    puts "RTT (Avg): #{@total_time / @total_count}ms"
  end

  private

  def send_request!(seq, sends_at)
    message = ICMPRequestPacket.new(seq, sends_at).message
    @sock.send(message, 0, @addr)
  end

  def receive_reply!(sent_at)
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
