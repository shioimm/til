require "socket"
require "ipaddr"

module MockGetaddrinfo
  ADDRESSES = {
    "localhost" => {
      Socket::AF_INET6 => ["::1"],
      Socket::AF_INET  => ["127.0.0.1"],
    }
  }

  class << self
    # TODO configを設定できるようにする
    def prepended(_)
      @config = { addresses: ADDRESSES, delay: nil, error: nil }
    end

    def getaddrinfo(hostname, service, family = nil, *, **)
      return super if numeric?(hostname)

      resolving_families(family).map { |family|
        raise @config[:error] if @config[:error]
        sleep @config[:delay] if @config[:delay]

        Addrinfo.tcp(@config[hostname][family], service)
      }
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
end

Addrinfo.singleton_class.prepend(MockGetaddrinfo)
