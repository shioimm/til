# 引用元: rubyネットワークプログラミング / 簡単なHTTP GET（Net::HTTP）
# http://www.geekpage.jp/programming/ruby-network/http-get-0.php
# 参照: https://docs.ruby-lang.org/ja/2.6.0/class/Net=3a=3aHTTP.html
# 参照: https://magazine.rubyist.net/articles/0013/0013-BundledLibraries.html

require 'net/http'

# Net::HTTPクラスはHTTPクライアントの操作を行う
result = Net::HTTP.get('www.ruby-lang.org', '/ja/')
# Net::HTTP.getはGETリクエストを送り、ボディのみを文字列として返す

p result

# インターネットに接続されている場合
# => "<!DOCTYPE html>\n<html>\n  <head>\n    <meta charset=\"utf-8\">\n\n    \n    <title>\xE3\x82\xAA\xE3\x83\x96\xE3\x82\xB8\xE3\x82\xA7\xE3\x82\xAF\xE3\x83\x88\xE6\x8C\x87\xE5\x90\x91\xE3\x82\xB9\xE3\x82\xAF\xE3\x83\xAA\xE3\x83\x97\xE3\x83\x88\xE8\xA8\x80\xE8\xAA\x9E Ruby</title>...

# インターネットに接続されていない場合、
# => Failed to open TCP connection to www.ruby-lang.org:80 (getaddrinfo: nodename nor servname provided, or not known) (SocketError)
