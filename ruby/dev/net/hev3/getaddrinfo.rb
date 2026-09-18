require "socket"
require "ipaddr"

module MockGetaddrinfo
  ADDRESSES = {
    "localhost" => {
      Socket::AF_INET6 => ["::1"],
      Socket::AF_INET  => ["127.0.0.1"],
    }
  }

  @config = { addresses: ADDRESSES, delay: nil, error: nil }

  class << self
    attr_reader :config
  end

  def getaddrinfo(hostname, service, family = nil, *, **)
    return super if numeric?(hostname)

    config = MockGetaddrinfo.config
    addresses = config[:addresses].fetch(hostname) do
      raise SocketError, "no mock addresses configured for #{hostname}"
    end

    raise config[:error] if config[:error]
    sleep config[:delay] if config[:delay]

    resolving_families(family).flat_map do |resolved_family|
      addresses.fetch(resolved_family, []).map do |address|
        Addrinfo.tcp(address, service)
      end
    end
  end

  private

  def resolving_families(family)
    case family
    when Socket::AF_INET6, Socket::AF_INET then [family]
    else [Socket::AF_INET6, Socket::AF_INET]  # nil / AF_UNSPEC
    end
  end

  def numeric?(hostname)
    IPAddr.new(hostname) && true
  rescue IPAddr::InvalidAddressError
    false
  end
end

Addrinfo.singleton_class.prepend(MockGetaddrinfo)
