require "socket"
require "optparse"

class Ping
  class ICMPRequestPacket
    def initialize(id, seq, sends_at)
      @id = id & WORD_MASK   # 16bit内に収める
      @seq = seq & WORD_MASK # 16bit内に収める
      @sends_at = sends_at
    end

    def message
      header = [TYPE, CODE, 0, @id, @seq].pack("C C n n n")

      checksum = calc_checksum(header + payload)
      checksum_size = 2 # 16bit
      header[2, checksum_size] = [checksum].pack("n")

      header + payload
    end

    private

    TYPE = 8
    CODE = 0
    WORD_MASK = 0xFFFF
    PAD_OCTET = "\x00".b

    def payload
      @payload ||= (
        timestamp = [@sends_at.to_i, @sends_at.usec].pack("N N")
        payload_size = Ping::ICMP_MESSAGE_SIZE - Ping::ICMP_HEADER_SIZE
        pad_size = payload_size - timestamp.bytesize

        if pad_size.negative?
          raise ArgumentError, "#{self.class}: Too small request payload (#{payload_size} < #{timestamp.bytesize})"
        end

        timestamp + (PAD_OCTET * pad_size)
      )
    end

    def calc_checksum(bin)
      sum = 0

      bin.bytes.each_slice(2) do |hi, lo| # 16bitごとに読み出す
        high_order_8_bits = (hi || 0) << 8 # 左に8bitシフト
        low_order_8_bits = lo || 0

        sum += (high_order_8_bits + low_order_8_bits)

        lower_16_bits = sum & WORD_MASK # 下位16bitを取得
        carry = sum >> 16 # 16bitを超えた部分を取得
        sum = lower_16_bits + carry # 16bitを超えた分を折り返す
      end

      (~sum) & WORD_MASK # sumをビット反転 -> 下位16bitを取得してチェックサム値とする
    end
  end

  class ICMPReplyPacket
    attr_reader :received_bytes, :from, :ttl, :rtt, :id, :seq, :type, :code

    def initialize(raw_message, addr, sent_at, received_at)
      @raw_message = raw_message
      @from = addr.ip_address
      @sent_at = sent_at
      @received_at = received_at

      parse_reply_message!
    end

    private

    ICMP_TIMESTAMP_SIZE = 8
    LOWER_4BIT_MASK = 0xF
    FLAGS_MASK = 0x7 # 0000 0111
    FRAGMENT_OFFSET_MASK = 0x1FFF # 0001 1111 1111 1111


    def parse_reply_message!
      ip_header = parse_ip_header
      raise "Not ICMP packet (#{ip_header.protocol})" if ip_header.protocol != Socket::IPPROTO_ICMP

      icmp_offset = ip_header.ihl
      icmp_payload_offset = icmp_offset + Ping::ICMP_HEADER_SIZE
      raise "Too short packet" if @raw_message.bytesize < icmp_payload_offset

      icmp = @raw_message.byteslice(icmp_offset, Ping::ICMP_HEADER_SIZE)
      icmp_header = parse_icmp_header(icmp)

      @ttl = ip_header.ttl

      @type = icmp_header.type
      @code = icmp_header.code
      @id = icmp_header.id
      @seq = icmp_header.seq

      @received_bytes = parse_received_bytes(ip_header, icmp_offset)
      @rtt = parse_rtt(icmp_payload_offset)
    end

    IPHeader = Data.define(
      :version,         # バージョン (4bit)
      :ihl,             # ヘッダ長 (4bit)
      :tos,             # TOS (8bit)
      :total_length,    # パケット長 (16bit)
      :id,              # 識別子  (16bit)
      :flags,           # フラグ (3bit)
      :fragment_offset, # フラグメントオフセット (13bit)
      :ttl,             # TTL (8bit)
      :protocol,        # トランスポート層のプロトコル (8bit)
      :checksum,        # IPヘッダのチェックサム (16bit)
      :src,             # 送信元IPアドレス (32bit)
      :dst,             # 宛先IPアドレス (32bit)
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
        version: (raw_vihl >> 4) & LOWER_4BIT_MASK,
        ihl: (raw_vihl & LOWER_4BIT_MASK) * 4,
        tos:,
        total_length:,
        id:,
        flags: (raw_flags >> 13) & FLAGS_MASK,
        fragment_offset: raw_flags & FRAGMENT_OFFSET_MASK,
        ttl:,
        protocol:,
        checksum:,
        src: bin_to_ipv4_address(raw_src),
        dst: bin_to_ipv4_address(raw_dst),
      )
    end

    def bin_to_ipv4_address(bin)
      [bin].pack("N").unpack("C4").join(".")
    end

    ICMPHeader = Data.define(
      :type,     # タイプ (8bit)
      :code,     # コード (Echo Replyの場合は0) (8bit)
      :checksum, # ICMPヘッダのチェックサム (16bit)
      :id,       # 識別子 (Echo Replyの場合) (16bit)
      :seq       # シーケンス番号 (Echo Replyの場合) (16bit)
    )

    def parse_icmp_header(icmp)
      ICMPHeader.new(*icmp.unpack("C C n n n"))
    end

    def parse_received_bytes(ip_header, icmp_offset)
      ip_payload_length = ip_header.total_length - icmp_offset
      raw_tail_length = @raw_message.bytesize - icmp_offset
      ip_payload_length.between?(0, raw_tail_length) ? ip_payload_length : raw_tail_length
    end

    def parse_rtt(icmp_payload_offset)
      icmp_payload_length = [@received_bytes - Ping::ICMP_HEADER_SIZE, 0].max
      icmp_payload = @raw_message.byteslice(icmp_payload_offset, icmp_payload_length) || "".b
      sent_at = icmp_payload.bytesize >= ICMP_TIMESTAMP_SIZE ? Time.at(*icmp_payload.unpack("N N")) : @sent_at
      ((@received_at - sent_at) * 1000).round(3)
    end
  end

  ICMP_HEADER_SIZE = 8
  ICMP_MESSAGE_SIZE = 64
  MAX_PACKET_SIZE = 2048

  def self.run!(dest, count: 5, timeout: 1)
    new(dest, count, timeout).run!
  end

  def initialize(dest, count, timeout)
    @dest = dest
    @count = count
    @timeout = timeout
    @id = Process.pid
    @total_time = 0
    @total_count = 0

    @sock = Socket.new(Socket::AF_INET, Socket::SOCK_RAW, Socket::IPPROTO_ICMP)
    @addr = Socket.sockaddr_in(0, dest)
  end

  def run!
    @count.times do |i|
      sends_at = Time.now
      seq = i + 1

      send_request!(seq, sends_at)
      reply = receive_reply!(sends_at)

      if !reply.type.zero? || !reply.code.zero? || reply.id != (@id & 0xFFFF) || reply.seq != (seq & 0xFFFF)
        warn "Skip unrelated ICMP: type=#{reply.type}, code=#{reply.code}, id=#{reply.id}, seq=#{reply.seq}"
        next
      end

      puts "#{reply.received_bytes} bytes from #{reply.from}: seq=#{seq} ttl=#{reply.ttl} rtt=#{reply.rtt} ms"

      @total_time += reply.rtt
      @total_count += 1

      sleep 1
    end

    puts "--- #{@dest} ping statistics ---"
    puts "#{@count} transmitted, #{@total_count} packets received, #{@total_count / @count.to_f}% packet loss"
    puts "round-trip avg = #{(@total_time / @total_count).round(3)}ms"
  ensure
    @sock&.close
  end

  private

  def send_request!(seq, sends_at)
    message = ICMPRequestPacket.new(@id, seq, sends_at).message
    @sock.send(message, 0, @addr)
  end

  def receive_reply!(sent_at)
    r, _ = IO.select([@sock], nil, nil, @timeout)

    raise "Receive timeout (#{@timeout} s)" if r.none?

    message, addr = @sock.recvfrom(MAX_PACKET_SIZE)
    received_at = Time.now
    ICMPReplyPacket.new(message, addr, sent_at, received_at)
  end
end

params = {}

opt = OptionParser.new
opt.on("-c", "--count") { params[:count] = it }
opt.on("-t", "--timeout") { params[:timeout] = it }

dest = ARGV.first

begin
  raise "Missing ping target" if dest.nil?

  Ping.run!(dest, **params)
rescue => e
  puts e.full_message
end
