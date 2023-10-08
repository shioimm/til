require 'socket'

RESOLUTION_DELAY = 0.05

hostname = 'localhost'
port = 9292

controller = Ractor.new do
  pickable_addrinfos = []
  is_ip6_resolved = false
  is_ip4_resolved = false

  loop do
    client, request, arg = Ractor.receive

    response = case request
               when :add_addrinfos # IPアドレス
                 pickable_addrinfos.push *arg
                 true
               when :pick_addrinfo
                 last_pattern = arg[:last_addrinfo]&.match?(/:/) ? /:/ : /./

                 if last_pattern &&
                     (addrinfo = pickable_addrinfos.find { |addrinfo| !addrinfo.match?(last_pattern) })
                   pickable_addrinfos.delete addrinfo
                 else
                   pickable_addrinfos.shift
                 end
               when :ip6_resolved
                 is_ip6_resolved = true
                 true
               when :ip4_resolved
                 is_ip4_resolved = true
                 true
               when :is_ip6_resolved # RESOLUTION_DELAY用
                 is_ip6_resolved
               else
                 nil
               end

    client.send response

    if is_ip6_resolved && is_ip4_resolved
      close_incoming
      close_outgoing
    end
  end
end

[:PF_INET6, :PF_INET].each do |family|
  Ractor.new(controller, hostname, port, family) do |controller, hostname, port, family|
    addrinfos = Addrinfo.getaddrinfo(hostname, port, family, :STREAM)
    ip_addresses = addrinfos.map(&:ip_address)

    # Resolution Delay
    if family == :PF_INET
      controller.send [Ractor.current, :is_ip6_resolved]
      is_ip6_resolved = Ractor.receive
      sleep RESOLUTION_DELAY unless is_ip6_resolved
    end

    controller.send [Ractor.current, :add_addrinfos, ip_addresses]
    Ractor.receive
  end
end

addrinfos = []
is_ip6_resolved = false
is_ip4_resolved = false
resolv_timeout = 1
last_addrinfo = nil

loop do
  controller.send [Ractor.current, :pick_addrinfo, { last_addrinfo: last_addrinfo }]
  ip_address = Ractor.receive

  next unless ip_address

  if !is_ip6_resolved && ip_address.match?(/:/)
    controller.send [Ractor.current, :ip6_resolved]
    is_ip6_resolved = true
    Ractor.receive # => true
  end

  if !is_ip4_resolved && ip_address.match?(/\./)
    controller.send [Ractor.current, :ip4_resolved]
    is_ip4_resolved = true
    Ractor.receive # => true
  end

  addrinfos.push Addrinfo.ip(ip_address)
  break if addrinfos.any?(&:ipv4?) && addrinfos.any?(&:ipv6?)

  last_addrinfo = ip_address
end

p addrinfos
