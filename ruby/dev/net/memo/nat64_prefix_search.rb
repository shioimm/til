require "socket"
require "resolv"
require "ipaddr"

class NAT64PrefixSearcher
  IPV4ONLY_ARPA = "ipv4only.arpa"

  # ipv4only.arpaの既知IPv4アドレス
  WELL_KNOWN_IPV4_ADDRESSES = [
    IPAddr.new("192.0.0.170").to_i,
    IPAddr.new("192.0.0.171").to_i,
  ].freeze

  # RFC6052で使用されるNAT64 prefix length候補
  NAT64_PREFIX_LENGTHS = [32, 40, 48, 56, 64, 96].freeze

  TIMEOUTS = [2, 4].freeze

  def initialize
    @addresses = []
  end

  def query_ipv4only_arpa
    Resolv::DNS.open do |dns|
      dns.timeouts = TIMEOUTS

      @addresses = dns.getresources(IPV4ONLY_ARPA, Resolv::DNS::Resource::IN::AAAA).map do |rr|
        int = IPAddr.new_ntoh(rr.address.address).to_i
        AddrInt.new(int)
      end
    end
  rescue Resolv::ResolvError, Resolv::ResolvTimeout => e
    warn "DNS query failed: #{e.class}: #{e.message}"
    exit
  end

  def detect_nat64_prefixes
    prefixed_observed_v4s = Hash.new { |h, k| h[k] = Set.new }
    confirmed = Set.new
    tentative = Set.new

    @addresses.each do |addr_int|
      NAT64_PREFIX_LENGTHS.each do |prefix_len|
        next if prefix_len < 96 && !addr_int.u_octet_zero?

        v4 = addr_int.embedded_ipv4(prefix_len)
        next if !WELL_KNOWN_IPV4_ADDRESSES.include?(v4)

        label = addr_int.label
        prefixed_observed_v4s[label] << v4

        if WELL_KNOWN_IPV4_ADDRESSES.all? { prefixed_observed_v4s[label].include?(it) }
          confirmed << label
          tentative.delete(label)
        else
          tentative << label
        end
      end
    end

    [confirmed.to_a, tentative.to_a]
  end

  class AddrInt
    def initialize(int)
      @int = int
    end

    def to_int
      @int
    end

    def u_octet_zero?
      ((@int >> 56) & 0xff).zero?
    end

    def embedded_ipv4(prefix_len)
      case prefix_len
      when 96
        # bytes 12..15, bits 96..127
        @int & 0xffffffff
      when 64
        # bytes 9..12, bits 72..103
        (@int >> 24) & 0xffffffff
      when 56
        # byte 7 + bytes 9..11 | bits 56..63 + bits 72..95
        (((@int >> 64) & 0xff) << 24) | ((@int >> 32) & 0xffffff)
      when 48
        # bytes 6..7 + bytes 9..10 |  bits 48..63 + bits 72..87
        (((@int >> 64) & 0xffff) << 16) | ((@int >> 40) & 0xffff)
      when 40
        # bytes 5..7 + byte 9 |  bits 40..63 + bits 72..79
        (((@int >> 64) & 0xffffff) << 8) | ((@int >> 48) & 0xff)
      when 32
        # bytes 4..7, bits 32..63
        (@int >> 64) & 0xffffffff
      else
        nil
      end
    end

    def label(prefix_len)
      "#{IPAddr.new(nat64_prefix(prefix_len), Socket::AF_INET6)}/#{prefix_len}"
    end

    private

    def nat64_prefix(prefix_len)
      shift = 128 - prefix_len
      (@int >> shift) << shift
    end
  end

  private_constant :AddrInt
end

searcher = NAT64PrefixSearcher.new
answers = searcher.query_ipv4only_arpa

if answers.empty?
  puts "AAAA not found"; exit
end

puts "AAAA responses:"

answers.each do
  puts "  #{IPAddr.new(it.to_int, Socket::AF_INET6)}"
end

confirmed, tentative = searcher.detect_nat64_prefixes

if confirmed.empty? && tentative.empty?
  puts "AAAA response was received, but it may not be a NAT64 composite address in RFC 6052 format."; exit
end

if !confirmed.empty?
  puts "NAT64 prefix confirmed:"
  confirmed.each { puts "  #{it}" }
end

if !tentative.empty?
  puts "NAT64 prefix tentative:"
  tentative.each { puts "  #{it}" }
end
