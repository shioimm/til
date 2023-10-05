require 'socket'

RESOLUTION_DELAY = 0.05

hostname = 'localhost'
port = 9292
families = [:PF_INET6, :PF_INET]

# TODO RESOLUTION_DELAYを入れたい

pipe = Ractor.new do
  loop do
    addrinfos = Ractor.receive
    Ractor.yield addrinfos
  end
end

ipv6_ractor = Ractor.new(pipe, hostname, port, :PF_INET6) do |pipe, hostname, port, family|
  addrinfos = Addrinfo.getaddrinfo(hostname, port, family, :STREAM)
  ip_addresses = addrinfos.map(&:ip_address)
  pipe.send ip_addresses
end

ipv4_ractor = Ractor.new(pipe, hostname, port, :PF_INET) do |pipe, hostname, port, family|
  addrinfos = Addrinfo.getaddrinfo(hostname, port, family, :STREAM)
  ip_addresses = addrinfos.map(&:ip_address)
  pipe.send ip_addresses
end

pickable_addrinfos = []

loop do
  ip_addresses = pipe.take
  addrinfos = ip_addresses.map { |ip_address| Addrinfo.ip(ip_address) }
  pickable_addrinfos.push *addrinfos
  break if pickable_addrinfos.any?(&:ipv4?) && pickable_addrinfos.any?(&:ipv6?)
end

p pickable_addrinfos
