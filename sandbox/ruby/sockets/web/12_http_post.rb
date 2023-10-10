# 引用元: rubyネットワークプログラミング / HTTP POST（Net::HTTP）
# http://www.geekpage.jp/programming/ruby-network/http-post-0.php
# 参照: https://docs.ruby-lang.org/ja/2.6.0/class/Net=3a=3aHTTP.html

require 'net/http'

http = Net::HTTP.new('www.ruby-lang.org')

response = http.post('/ja/', 'ei=UTF-8&p=test')
# Net::HTTP#postはPOSTリクエストを送り、Net::HTTPResponseのインスタンスを返す

p response.body

# => "<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n  <meta charset=\"utf-8\">\n  <title>Error</title></head>\n<body>\n  <p>405: Method Not Allowed</p>\n</body>\n</html>\n"
