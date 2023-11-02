# 状態遷移
#   - start
#   - v4w
#   - v4c
#   - v6c
#   - v46c
#   - success
#   - failure

state = :start
resolving_fds = []
resolved_ips = []
ip_candidates = []
connecting_fds = []
resolving_threads = ThreadGroup.new

resolv_timeout = nil # オプション
connect_timeout = nil # オプション

connected_fd = nil

loop do
  case state
  when :start
    [ipv4, ipv6].each { |family|
      resolving_threads.add Thread.new {
        r, w = Pipe.new
        resolving_fds << r
        resolved_ips.concat(Addrinfo.getaddrinfo)
        w << family
      }
    }

    ret = select(resolving_fds, resolv_timeout)

    if ret == ipv4
      state = :v4w
    elsif == ipv6
      state = :v6c
    else # resolv_timeout
      state = :resolv_timeout
    end
  when :v4w
    ret = select(resolving_fds, resolution_delay_timeout)

    if ret == ipv6
      ip_candidates.concat(ipv6.result_ips)
      state = :v46c
    else
      state = :v4c
    end
  when :v4c
  when :v6c
  when :v46c
  when :success
    return connected_fd
  when :failure
    # 全ての接続に失敗しているケース
    # 現在のSocket.tcpの仕様ではconnect_timeoutが指定されていない場合は接続を待ち続けるので、
    # ここに到達してしまうと既存の挙動が変更されることになる
  when :resolv_timeout
  when :connect_timeout
    raise
  end
end
