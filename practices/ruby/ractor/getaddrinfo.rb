require 'socket'

def resolv_hostname(hostname, port, family)
  Ractor.new(hostname, port, family, name: family.to_s.downcase) do |hostname, port, family|
    Addrinfo.getaddrinfo(hostname, port, family, :STREAM)
  end
end

hostname = 'localhost'
port = 9292
families = [:PF_INET6, :PF_INET]

hostname_resolution_ractors = families.map do |family|
  resolv_hostname(hostname, port, family)
end

ractor, addrinfos = Ractor.select(*hostname_resolution_ractors)

p ractor
p addrinfos.first
