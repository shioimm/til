require "net/http"
require "resolv"

NAMESERVER = ["127.0.0.1", 5300]
HOST = "localhost"
HTTPS_PORT = 8443
HTTP_PORT = 8080

resolver = Resolv::DNS.new(nameserver_port: [NAMESERVER])
a_records = resolver.getresources(HOST, Resolv::DNS::Resource::IN::A).map { it.address.to_s }

http =
  if ARGV[0] == :https
    h = Net::HTTP.new(a_records.first, HTTPS_PORT)
    h.use_ssl = true
    h.verify_mode = OpenSSL::SSL::VERIFY_NONE
    h
  else
    Net::HTTP.new(a_records.first, HTTP_PORT)
  end

request = Net::HTTP::Get.new("/")
request["Host"] = HOST

response = http.request(request)
p response
