require "http"

res = HTTP.get('https://example.com')
puts res.body
puts("---")
p res
# #<HTTP::Response/1.1 200 OK
#   {
#     "Content-Type" => "text/html",
#     "ETag" => "\"84238dfc8092e5d9c0dac8ef93371a07:1736799080.121134\"",
#     "Last-Modified" => "Mon, 13 Jan 2025 20:11:20 GMT",
#     "Cache-Control" => "max-age=694",
#     "Date" => "Fri, 28 Mar 2025 22:40:53 GMT",
#     "Alt-Svc" => "h3=\":443\"; ma=93600,h3-29=\":443\"; ma=93600,quic=\":443\"; ma=93600; v=\"43\"",
#     "Content-Length" => "1256",
#     "Connection" => "close"
#   }
# >
p res.headers # HTTP::Headers
p res.headers["Last-Modified"]

__END__
$ gem i http
Fetching ffi-compiler-1.3.2.gem
Fetching llhttp-ffi-0.5.1.gem
Fetching http-form_data-2.3.0.gem
Fetching http-5.2.0.gem
Successfully installed ffi-compiler-1.3.2
Building native extensions. This could take a while...
Successfully installed llhttp-ffi-0.5.1
Successfully installed http-form_data-2.3.0
Successfully installed http-5.2.0
Parsing documentation for ffi-compiler-1.3.2
Installing ri documentation for ffi-compiler-1.3.2
Parsing documentation for llhttp-ffi-0.5.1
Installing ri documentation for llhttp-ffi-0.5.1
Parsing documentation for http-form_data-2.3.0
Installing ri documentation for http-form_data-2.3.0
Parsing documentation for http-5.2.0
Installing ri documentation for http-5.2.0
Done installing documentation for ffi-compiler, llhttp-ffi, http-form_data, http after 0 seconds
4 gems installed
