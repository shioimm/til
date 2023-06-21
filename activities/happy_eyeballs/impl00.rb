require 'resolv'

# TODO:
# AクエリとAAAAクエリをRFC8305に従ってそれぞれ送信する
# 取得したIPv4/IPv6アドレスをソートする (後回し)
# ソートしたアドレスをRFC8305に従って接続試行する
addrs = Resolv.getaddresses("www.example.com")
p addrs # これだとIPv4/IPv6が両方とも取得できてしまうので別々にクエリを送信する方法を見つける
