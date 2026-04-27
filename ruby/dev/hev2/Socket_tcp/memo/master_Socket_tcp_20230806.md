# 現状の実装 (2023/8/6時点)
https://github.com/ruby/ruby/blob/master/ext/socket/lib/socket.rb

```ruby
# local_hostやlocal_portを指定した場合、接続ソケットをそこにバインドする
def self.tcp(host,
             port,
             local_host = nil,
             local_port = nil,
             connect_timeout: nil,
             resolv_timeout: nil) # :yield: socket

  last_error = nil
  ret = nil
  local_addr_list = nil

  if local_host != nil || local_port != nil
    # local_hostかlocal_portがある場合は接続ソケットにバインドするためのアドレスリストを取得しておく
    local_addr_list = Addrinfo.getaddrinfo(local_host, local_port, nil, :STREAM, nil)
  end

  # サーバのアドレス一覧を取得して順に処理
  Addrinfo.foreach(host, port, nil, :STREAM, timeout: resolv_timeout) {|ai|
    if local_addr_list
      # アドレスファミリの一致するアドレスがあればlocal_addrへ保存
      local_addr = local_addr_list.find {|local_ai| local_ai.afamily == ai.afamily }
      next unless local_addr
    else
      local_addr = nil
    end

    begin
      sock = local_addr ?
        ai.connect_from(local_addr, timeout: connect_timeout) : # local_addrからaiへ接続試行
        ai.connect(timeout: connect_timeout)                    # aiへ接続試行
    rescue SystemCallError
      last_error = $!
      next
    end
    ret = sock
    break # 接続に成功したらループから抜ける
  }

  # 接続ソケットが得られなかった場合
  unless ret
    if last_error
      raise last_error
    else
      raise SocketError, "no appropriate local address"
    end
  end

  if block_given?
    begin
      yield ret
    ensure
      ret.close
    end
  else
    ret
  end
end
```
