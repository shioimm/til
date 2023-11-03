# 状態遷移
- 「未接続のaddrinfoの在庫が枯渇、すべてのfdが接続中」の状態が必要な気がする

```
case start
  resources
    # なし
  do
    IPv6 getaddrinfo開始
    IPv4 getaddrinfo開始
    # TODO アドレス解決中にエラーが起こった場合はどうする? -> どちらかのファミリで発生した場合 / 両方で発生した場合
  transition
    IPv6アドレス解決 -> v6c # 未接続のIPv6 addrinfoあり
    IPv4アドレス解決 -> v4w # 未接続のIPv4 addrinfoあり
    resolv_timeout   -> timeout

case v6c
  resources
    # TODO
  do
    if 未接続のIPv6 addrinfoの在庫がある
      connect
      select([IPv6 fds, IPv4アドレス解決], CONNECTION_ATTEMPT_DELAY)
    if 未接続のIPv6 addrinfoの在庫がない
      select([IPv6 fds, IPv4アドレス解決])
      # TODO 未接続のaddrinfoの在庫が枯渇しており、すべてのfdが接続中の状態
      # このままだと永久に待ち続ける可能性あり、どこかでクエリを打ち切ってv46cに遷移する必要がある
      # その場合v46cに遷移した時点では単に接続中のIPv6 fdありの状態になる
  transition
    if 未接続のIPv6 addrinfoの在庫がある
      CONNECTION_ATTEMPT_DELAY中にconnectに成功 -> success # 接続済みのIPv6 fdあり、接続中のIPv6 fdありの可能性あり
      CONNECTION_ATTEMPT_DELAYタイムアウト -> v6cに戻る # 接続中のIPv6 fdあり
      IPv4アドレス解決 -> v46c # 接続中のIPv6 fdあり、未接続のIPv4 addrinfoあり
    if 未接続のIPv6 addrinfoの在庫がない
      connectに成功 -> success # 接続済みのIPv6 fdあり、接続中のIPv6 fdがある可能性あり
      IPv4アドレス解決 -> v46c # 接続中のIPv6 fdあり、未接続のIPv4 addrinfoあり

case v4w
  resources
    # TODO
  do
    RESOLUTION_DELAY
  transition
    RESOLUTION_DELAY中にIPv6アドレス解決 -> v46c # 接続中のfdなし、未接続のIPv6 / IPv4 addrinfoあり
    RESOLUTION_DELAYタイムアウト -> v4c # 接続中のfdなし、未接続のIPv4 addrinfoあり

case v4c
  resources
    # TODO
  do
    if 未接続のIPv4 addrinfoの在庫がある
      connect
      select([IPv4 fds, IPv6アドレス解決], CONNECTION_ATTEMPT_DELAY)
    if 未接続のIPv4 addrinfoの在庫がない
      select([IPv4 fds, IPv6アドレス解決])
      # TODO 未接続のaddrinfoの在庫が枯渇しており、すべてのfdが接続中の状態
      # このままだと永久に待ち続ける可能性あり、どこかでクエリを打ち切ってv46cに遷移する必要がある
      # その場合v46cに遷移した時点では単に接続中のIPv6 fdありの状態になる
  transition
    if 未接続のIPv4 addrinfoの在庫がある
      CONNECTION_ATTEMPT_DELAY中にconnectに成功 -> success # 接続済みのIPv4 fdあり、接続中のIPv4 fdありの可能性あり
      CONNECTION_ATTEMPT_DELAYタイムアウト -> v6cに戻る # 接続中のIPv4 fdあり
      IPv6アドレス解決 -> v46c # 接続中のIPv4 fdあり、未接続のIPv6 addrinfoあり
    if 未接続のIPv4 addrinfoの在庫がない
      connectに成功 -> success # 接続済みのIPv4 fdあり、接続中のIPv4 fdがある可能性あり
      IPv6アドレス解決 -> v46c  # 接続中のIPv4 fdあり、未接続のIPv6 addrinfoあり

case v46c
  resources
    # TODO
  do
    if 未接続のaddrinfoの在庫がある
      if 接続中のfdがある
        if 前回の接続のCONNECTION_ATTEMPT_DELAY中
          CONNECTION_ATTEMPT_DELAY
        if 前回の接続のCONNECTION_ATTEMPT_DELAYタイムアウト済み
          アドレス選択
          connect
          select([fds], CONNECTION_ATTEMPT_DELAY)
      if 接続中のfdがない
        IPv6優先してconnect
        select([fds], CONNECTION_ATTEMPT_DELAY)
    if 未接続のaddrinfoの在庫がない
      # 処理なし
  transition
    if 未接続のaddrinfoの在庫がある
      CONNECTION_ATTEMPT_DELAYタイムアウト前にconnectに成功 -> success
      CONNECTION_ATTEMPT_DELAYタイムアウト -> v46cに戻る
    if 未接続のaddrinfoの在庫がない
      すべてのfdが接続中 -> ???
      すべてのfdの接続に失敗 -> failure

case ???
  resources
    # TODO
  do
    if 接続中のソケットがある
      if 前回の接続のCONNECTION_ATTEMPT_DELAY中
        CONNECTION_ATTEMPT_DELAY
      if 前回の接続のCONNECTION_ATTEMPT_DELAYタイムアウト済み
        アドレス選択してconnect
    if 接続中のソケットがない
      # 処理なし
  transition
    if 接続中のソケットがある
      CONNECTION_ATTEMPT_DELAYタイムアウト前にconnectに成功 -> success
      CONNECTION_ATTEMPT_DELAYタイムアウト -> ???に戻る
    if 接続中のソケットがない
      すべてのfdの接続に失敗 -> failure

case success
  resources
    # TODO
  do
    cleanup
    return 接続済みfd

case failure
  resources
    # TODO
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

- 「未接続のaddrinfoの在庫が枯渇しており、すべてのfdが接続中の状態」は
  impl14では`resolution_state[:ipv6_done] && resolution_state[:ipv4_done] && pickable_addrinfos.empty?`の場合
  それ以上アドレス解決を待たないようにしている
  - 最初にアドレス解決がなされて以降、`pickable_addrinfos`に解決済みのaddrinfoが勝手に入ってくるイメージ
