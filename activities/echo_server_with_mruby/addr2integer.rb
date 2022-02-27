# ref: https://github.com/ruby/ipaddr/blob/683706cc618748365037243b620e5ad79b46ccfd/lib/ipaddr.rb#L645

class Addr2Integer
  RE_IPV4ADDRLIKE = %r{
    \A
    (\d+) \. (\d+) \. (\d+) \. (\d+)
    \z
  }x

  def self.convert(addr)
    m = RE_IPV4ADDRLIKE.match(addr)
    octets = m.captures
    octets.inject(0) { |i, s|
      (n = s.to_i) < 256
      s.match(/\A0./)
      i << 8 | n
    }
  end
end
