# 状態遷移
- 「未接続のaddrinfoの在庫が枯渇、すべてのfdが接続中」の状態が必要な気がする

```
case start
  do
    IPv6 getaddrinfo開始
    IPv4 getaddrinfo開始
    # アドレス解決中にエラーが起こった場合はどうする? -> どちらかのファミリで発生した場合 / 両方で発生した場合
  transition
    IPv6アドレス解決 -> v6c
    IPv4アドレス解決 -> v4w
    resolv_timeout   -> timeout

case v6c
  do
    if 未接続のIPv6 addrinfoの在庫がある
      connect
    if 未接続のIPv6 addrinfoの在庫がない
      IPv4アドレス解決を待つ
  transition
    if 未接続のIPv6 addrinfoの在庫がある
      CONNECTION_ATTEMPT_DELAY中にconnectに成功 -> success # 接続済みのIPv4 fdあり、接続中のIPv4 fdありの可能性あり
      CONNECTION_ATTEMPT_DELAYタイムアウト -> v6cに戻る # 接続中のIPv4 fdあり
    if 未接続のIPv6 addrinfoの在庫がない
      IPv4アドレス解決 -> v46c # 接続中のIPv4 fdあり、未接続のIPv6 addrinfoあり

case v4w
  do
    RESOLUTION_DELAY
  transition
    RESOLUTION_DELAY中にIPv6アドレス解決 -> v46c # 接続中のfdなし、未接続のIPv6 / IPv4 addrinfoあり
    RESOLUTION_DELAYタイムアウト -> v4c

case v4c
  do
    if 未接続のIPv4 addrinfoの在庫がある
      connect
    if 未接続のIPv4 addrinfoの在庫がない
  transition
    CONNECTION_ATTEMPT_DELAY中にconnectに成功  -> success
    CONNECTION_ATTEMPT_DELAY中にIPv6アドレス解決 -> v46c
    CONNECTION_ATTEMPT_DELAYタイムアウト -> v6cに戻る
    未接続のaddrinfoの在庫が枯渇、すべてのfdが接続中 -> ???
    未接続のaddrinfoの在庫が枯渇、すべてのfdの接続に失敗 -> (このステートでIPv6アドレス解決を待つ)

case v46c
  do
    while 未接続のaddrinfoの在庫がある
      if 接続中のソケットがある
        if 前回の接続のCONNECTION_ATTEMPT_DELAY中
          CONNECTION_ATTEMPT_DELAYタイムアウトを待つ
        else
          アドレス選択してconnect
        end
      else
        IPv6優先してconnect
      end
    end
  transition
    CONNECTION_ATTEMPT_DELAYタイムアウト前にconnectに成功  -> success
    CONNECTION_ATTEMPT_DELAYタイムアウト -> v46cに戻る
    未接続のaddrinfoの在庫が枯渇、すべてのfdが接続中 -> ???
    未接続のaddrinfoの在庫が枯渇、すべてのfdの接続に失敗 -> failure

case success
  do
    cleanup
    return the established TCP connection

case ???
  do
    if 接続中のソケットがある
      if 前回の接続のCONNECTION_ATTEMPT_DELAY中
        CONNECTION_ATTEMPT_DELAYタイムアウトを待つ
      else
        アドレス選択してconnect
      end
    end
  transition
    CONNECTION_ATTEMPT_DELAYタイムアウト前にconnectに成功  -> success
    CONNECTION_ATTEMPT_DELAYタイムアウト -> ???に戻る
    すべてのfdの接続に失敗 -> failure

case failure
  do
    # 全てのfdの接続に失敗しているケース
    # 現在のSocket.tcpの仕様ではconnect_timeoutが指定されていない場合は接続を待ち続けるので、
    # ここに到達してしまうと既存の挙動が変更されることになる
    # このstateを許容するべきか考えるべき

case timeout
  do
    cleanup
    raise
```
