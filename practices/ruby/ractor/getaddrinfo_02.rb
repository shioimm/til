require 'socket'

RESOLUTION_DELAY = 0.05

hostname = 'localhost'
port = 9292
families = [:PF_INET6, :PF_INET]

# TODO RESOLUTION_DELAYを入れたい

controller = Ractor.new do
  addrinfos = []
  is_ip6_resolved = false

  loop do
    request = Ractor.receive

    response = case request
               when Array # IPアドレス
                 addrinfos.push *request
                 true
               when :addrinfos
                 pickable_addrinfos = addrinfos
                 addrinfos -= pickable_addrinfos
                 pickable_addrinfos
               when :ip6_resolved
                 is_ip6_resolved = true
                 true
               when :is_ip6_resolved # RESOLUTION_DELAY用
                 is_ip6_resolved
               else
                 nil
               end

    # TODO Main Ractorには明示的にsendし、Main Ractorではreceive_ifで受け取るようにする
    Ractor.yield response
  end
end

Ractor.new(controller, hostname, port, :PF_INET6) do |controller, hostname, port, family|
  addrinfos = Addrinfo.getaddrinfo(hostname, port, family, :STREAM)
  ip_addresses = addrinfos.map(&:ip_address)
  controller.send ip_addresses
  controller.take
end

Ractor.new(controller, hostname, port, :PF_INET) do |controller, hostname, port, family|
  addrinfos = Addrinfo.getaddrinfo(hostname, port, family, :STREAM)
  ip_addresses = addrinfos.map(&:ip_address)
  controller.send ip_addresses
  controller.take
end

addrinfos = []

loop do
  controller.send :addrinfos
  ip_addresses = controller.take
  addrinfos.push *ip_addresses.map { |ip_address| Addrinfo.ip(ip_address) }
  break if addrinfos.any?(&:ipv4?) && addrinfos.any?(&:ipv6?)
end

p addrinfos
