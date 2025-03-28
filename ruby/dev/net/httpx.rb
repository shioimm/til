require "httpx"

res = HTTPX.get("https://example.com")
puts res.body
puts("---")
p res
# #<Response:232
#   HTTP/2.0
#   @status=200
#   @headers={
#     "accept-ranges" => ["bytes"],
#     "content-type" => ["text/html"],
#     "etag" => ["\"84238dfc8092e5d9c0dac8ef93371a07:1736799080.121134\""],
#     "last-modified" => ["Mon, 13 Jan 2025 20:11:20 GMT"],
#     "vary" => ["Accept-Encoding"],
#     "content-encoding" => ["gzip"],
#     "cache-control" => ["max-age=412"],
#     "date" => ["Fri, 28 Mar 2025 00:59:46 GMT"],
#     "alt-svc" => ["h3=\":443\"; ma=93600,h3-29=\":443\"; ma=93600,quic=\":443\"; ma=93600; v=\"43\""],
#     "content-length" => ["648"]
#     }
#   @body=1256
# >
p res.status
p res.headers["last-modified"]
__END__
- res, res.headersともに無名クラスのインスタンスになっている
