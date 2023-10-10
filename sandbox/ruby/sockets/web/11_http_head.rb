# 引用元: rubyネットワークプログラミング / HTTP HEADと全てのHTTPヘッダの表示（Net::HTTP）
# http://www.geekpage.jp/programming/ruby-network/http-head-0.php
# 参照: https://docs.ruby-lang.org/ja/2.6.0/class/Net=3a=3aHTTP.html
# 参照: https://docs.ruby-lang.org/ja/2.6.0/class/Net=3a=3aHTTPResponse.html

require 'net/http'

http = Net::HTTP.new('www.ruby-lang.org')
response = http.head('/ja/')
# Net::HTTP#headはHEADリクエストを送り、Net::HTTPResponseのインスタンスを返す

p response
# => #<Net::HTTPOK 200 OK readbody=true>

p response.code
# Net::HTTPResponse#codeはステータスコードを文字列で返す
# => "200"

response.each { |name, value| pp "#{name}: #{value}" }

# =>
# "server: Cowboy"
# "strict-transport-security: max-age=31536000"
# "content-type: text/html"
# "etag: W/\"7e55d2a45f166e097c3ffbc1fa2e42de\""
# "x-frame-options: SAMEORIGIN"
# "via: 1.1 vegur, 1.1 varnish"
# "content-length: 9801"
# "accept-ranges: bytes"
# "date: Mon, 30 Dec 2019 02:38:39 GMT"
# "age: 372"
# "connection: close"
# "x-served-by: cache-hnd18732-HND"
# "x-cache: HIT"
# "x-cache-hits: 1"
# "x-timer: S1577673519.292820,VS0,VE0"
# "vary: Accept-Encoding"
