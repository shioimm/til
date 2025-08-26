require "socket"

class Ping
  class ICMPRequestPacket
    TYPE = 8
    CODE = 0
    WORD_MASK = 0xFFFF
    PAD_OCTET = "\x00".b

    def initialize(id, size, seq, sends_at)
      @id = id & WORD_MASK
      @seq = seq & WORD_MASK
      @sends_at = sends_at
      @message_size = size
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
        payload_size = @message_size - Ping::ICMP_HEADER_SIZE
        pad = PAD_OCTET * (payload_size - timestamp.bytesize)
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
    attr_reader :received_bytes, :from, :ttl, :rtt, :id, :seq, :type, :code

    def initialize(raw_message, addr, sent_at, received_at)
      @raw_message = raw_message
      @from = addr.ip_address
      @sent_at = sent_at
      @received_at = received_at
      @rtt = ((@received_at - @sent_at) * 1000).round(2)

      parse_reply_message!
    end

    private

    def parse_reply_message!
      ip_header = parse_ip_header
      raise "Not ICMP packet (#{ip_header.protocol})" if ip_header.protocol != Socket::IPPROTO_ICMP

      @ttl = ip_header.ttl

      icmp_offset = ip_header.ihl
      raise "Too short packet" if @raw_message.bytesize < icmp_offset + Ping::ICMP_HEADER_SIZE

      icmp = @raw_message.byteslice(icmp_offset, Ping::ICMP_HEADER_SIZE)
      icmp_header = parse_icmp_header(icmp)

      @type = icmp_header.type
      @code = icmp_header.code
      @id = icmp_header.id
      @seq = icmp_header.seq

      @received_bytes = @raw_message.size - icmp_offset
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

    def parse_ip_header
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

    def parse_icmp_header(icmp)
      ICMPHeader.new(*icmp.unpack("C C n n n"))
    end
  end

  ICMP_MESSAGE_SIZE = 64
  ICMP_HEADER_SIZE = 8
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

      if !reply.type.zero? || !reply.code.zero? || reply.id != (@id & 0xFFFF) || reply.seq != (seq & 0xFFFF)
        warn "Skip unrelated ICMP: type=#{reply.type}, code=#{reply.code}, id=#{reply.id}, seq=#{reply.seq}"
        redo
      end

      puts "#{reply.received_bytes} bytes from #{reply.from}: seq=#{seq} ttl=#{reply.ttl} rtt=#{reply.rtt} ms"

      @total_time += reply.rtt
      @total_count += 1

      sleep 1
    end

    puts "RTT (Avg): #{(@total_time / @total_count).round(2)}ms"
  ensure
    @sock&.close
  end

  private

  def send_request!(seq, sends_at)
    message = ICMPRequestPacket.new(@id, @size, seq, sends_at).message
    @sock.send(message, 0, @addr)
  end

  def receive_reply!(sent_at)
    r, _ = IO.select([@sock], nil, nil, @timeout)

    raise "Receive timeout (#{@timeout}s)" if r.none?

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
