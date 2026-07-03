require "net/http"
require "resolv"

HOST = "www.ruby-lang.org"

resolver = Resolv::DNS.new
a_records = resolver.getresources(HOST, Resolv::DNS::Resource::IN::A).map { it.address.to_s }

http = Net::HTTP.new(a_records.first)
request = Net::HTTP::Get.new("/")
request["Host"] = HOST

response = http.request(request)
p response
