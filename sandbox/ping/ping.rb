require "socket"

class Ping
  class ICMPRequestPacket
    TYPE = 8
    CODE = 0
    PAYLOAD_SIZE = 48
    WORD_MASK = 0xFFFF
    PAD_OCTET = "\x00".b

    def initialize(id, seq, sends_at)
      @id = id & WORD_MASK
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

  class ICMPReplyPacket
    attr_reader :message, :from, :ttl, :time

    def initialize(raw_message, addr, sent_at, received_at)
      @raw_message = raw_message
      @from = addr.ip_address
      @sent_at = sent_at
      @received_at = received_at
      @time = ((@received_at - @sent_at) * 1000).round(2)
      @message = "" # TEMP

      parse_reply_message!
    end

    private

    def parse_reply_message!
      ip_header = parse_ip_header!
      @ttl = ip_header.ttl

      icmp_offset = ip_header.ihl
      icmp = @raw_message.byteslice(icmp_offset, 8)
      icmp_header = parse_icmp_header!(icmp)

      # WIP
      # #<data Ping::ICMPReplyPacket::IPHeader version=4, ihl=20, tos=0, total_length=14336, id=58204, flags=0, frag_offset=0, ttl=64, protocol=1, checksum=0, src="127.0.0.1", dst="127.0.0.1">
      # #<data Ping::ICMPReplyPacket::ICMPHeader type=0, code=0, checksum=29722, id=65436, seq=1>
    end

    IPHeader = Data.define(
      :version,
      :ihl,
      :tos,
      :total_length,
      :id,
      :flags,
      :frag_offset,
      :ttl,
      :protocol,
      :checksum,
      :src,
      :dst,
    )

    def parse_ip_header!
      raw_vihl,
      tos,
      total_length,
      id,
      raw_flags,
      ttl,
      protocol,
      checksum,
      raw_src,
      raw_dst = @raw_message.unpack("C C n n n C C n N N")

      IPHeader.new(
        version: (raw_vihl >> 4) & 0xF,
        ihl: (raw_vihl & 0xF) * 4,
        tos:,
        total_length:,
        id:,
        flags: (raw_flags >> 13) & 0x7,
        frag_offset: raw_flags & 0x1FFF,
        ttl:,
        protocol:,
        checksum:,
        src: [raw_src].pack("N").unpack("C4").join("."),
        dst: [raw_dst].pack("N").unpack("C4").join("."),
      )
    end

    ICMPHeader = Data.define(:type, :code, :checksum, :id, :seq)

    def parse_icmp_header!(icmp)
      ICMPHeader.new(*icmp.unpack("C C n n n"))
    end
  end

  ICMP_MESSAGE_SIZE = 64
  MAX_PACKET_SIZE = 2048

  def self.execute!(dest)
    new(dest).execute!
  end

  def initialize(dest, count: 5, timeout: 1)
    @size = ICMP_MESSAGE_SIZE
    @count = count
    @timeout = timeout
    @id = Process.pid
    @total_time = 0
    @total_count = 0

    @sock = Socket.new(Socket::AF_INET, Socket::SOCK_RAW, Socket::IPPROTO_ICMP)
    @addr = Socket.sockaddr_in(0, dest)
  end

  def execute!
    @count.times do |i|
      sends_at = Time.now
      seq = i + 1

      send_request!(seq, sends_at)
      reply = receive_reply!(sends_at)

      puts "#{reply.message.size} bytes from #{reply.from}: seq=#{seq} ttl=#{reply.ttl} time=#{reply.time} ms"

      @total_time += 1 # WIP
      @total_count += 1 # WIP

      sleep 1
    end

    puts "RTT (Avg): #{@total_time / @total_count}ms"
  end

  private

  def send_request!(seq, sends_at)
    message = ICMPRequestPacket.new(@id, seq, sends_at).message
    @sock.send(message, 0, @addr)
  end

  def receive_reply!(sent_at)
    message, addr = @sock.recvfrom(MAX_PACKET_SIZE)
    received_at = Time.now
    ICMPReplyPacket.new(message, addr, sent_at, received_at)
  end
end

dest = ARGV.first

begin
  raise "Missing ping target" if dest.nil?

  Ping.execute!(dest)
rescue => e
  puts e.full_message
end
