# 状態遷移

```
case start
  resources
    なし
  do
    IPv6 getaddrinfo開始
      - IPv6アドレス解決 -> v6c
      - resolv_timeout   -> timeout
    IPv4 getaddrinfo開始
      - IPv4アドレス解決 -> v4w
      - resolv_timeout   -> timeout

    # TODO
    # アドレス解決中にエラーが起こった場合はどうする? (どちらかのファミリで発生した場合 / 両方で発生した場合)

# (IPv4アドレス解決中)
case v6c
  resources
    未接続のIPv6 addrinfos
    二周目以降、接続中のIPv6 fds
  do
    if 未接続のIPv6 addrinfoがある
      connect
      select([IPv6 fds, IPv4アドレス解決], CONNECTION_ATTEMPT_DELAY)
        - connectに成功                        -> success
        - IPv4アドレス解決                     -> v46c
        - CONNECTION_ATTEMPT_DELAYタイムアウト -> v6cに戻る

    else if 未接続のIPv6 addrinfoがない
      # 未解決のファミリがあり、未接続のaddrinfoの在庫が枯渇、すべてのfdが接続中
      select([IPv6 fds, IPv4アドレス解決])
        - connectに成功    -> success
        - IPv4アドレス解決 -> v46c

      # (注)
      # IPv6 fdsがすべて接続中またはすべて接続失敗し、A応答がないと永久に待ち続ける可能性あり
      # どこかでクエリを打ち切ってv46wait_to_resolv_or_connectに遷移する必要がある
      # -> v46wait_to_resolv_or_connect

# IPv6アドレス解決中
case v4w
  resources
    未接続のIPv4 addrinfos
  do
    RESOLUTION_DELAY
      - IPv6アドレス解決             -> v46c # 接続中のfdsなし、未接続のIPv6 / IPv4 addrinfosあり
      - RESOLUTION_DELAYタイムアウト -> v4c

# IPv6アドレス解決中
case v4c
  resources
    未接続のIPv4 addrinfos
    二周目以降、接続中のIPv4 fds
  do
    if 未接続のIPv4 addrinfoの在庫がある
      connect
      select([IPv4 fds, IPv6アドレス解決], CONNECTION_ATTEMPT_DELAY)
        - connectに成功                        -> success
        - IPv6アドレス解決した場合             -> v46c
        - CONNECTION_ATTEMPT_DELAYタイムアウト -> v4cに戻る

    else if 未接続のIPv4 addrinfoの在庫がない
      # 未解決のファミリがあり、未接続のaddrinfoの在庫が枯渇、すべてのfdが接続中
      select([IPv4 fds, IPv6アドレス解決])
        - connectに成功した場合    -> success
        - IPv6アドレス解決した場合 -> v46c

      # (注)
      # IPv4 fdsがすべて接続中またはすべて接続失敗し、AAAA応答がないと永久に待ち続ける可能性あり
      # どこかでクエリを打ち切ってv46wait_to_resolv_or_connectに遷移する必要がある
      # -> v46wait_to_resolv_or_connect

# すべてのファミリがアドレス解決済み、未接続のaddrinfosあり、接続中のfdsあり
case v46c
  resources
    未接続のaddrinfos
    接続中のfds (一周目はまだ存在しない可能性あり)
  do
    if 未接続のaddrinfoの在庫がある
      if 接続中のfdsがある
        if connect_timeout
          - タイムアウト済み -> timeout

        # TODO
        #   ループとselectどちらでCONNECTION_ATTEMPT_DELAYするべきか考える
        #   でもこのstateに遷移したタイミングでタイマーが残っている可能性があるので
        #   selectではCONNECTION_ATTEMPT_DELAYできない気がする...もうちょっとじっくり考える
        if 前回の接続のCONNECTION_ATTEMPT_DELAY中
          CONNECTION_ATTEMPT_DELAY
            - CONNECTION_ATTEMPT_DELAYタイムアウト -> v46cに戻る

        else if 前回の接続のCONNECTION_ATTEMPT_DELAYタイムアウト済み
          アドレス選択してconnect
          select([fds], CONNECTION_ATTEMPT_DELAY)
            # TODO
            #   ここ新しい接続とCONNECTION_ATTEMPT_DELAYを並行にできてない気がする
            #   selectせずに次のループに入るべきでは?そして接続中のfdがあるなら実行順はselect -> connectかも?
            - connectに成功                        -> success
            - CONNECTION_ATTEMPT_DELAYタイムアウト -> v46cに戻る

      else if 接続中のfdsがない
        IPv6を優先してconnect
        select([fds], CONNECTION_ATTEMPT_DELAY)
          - connectに成功                        -> success
          - CONNECTION_ATTEMPT_DELAYタイムアウト -> v46cに戻る

    else if 未接続のaddrinfoの在庫がない
      - すべてのfdが接続中     -> v46wait_to_resolv_or_connect
      - すべてのfdの接続に失敗 -> failure

# 追加
# 未解決のアドレスがある可能性あり、未接続のaddrinfosなし、接続中のfdsあり
case v46wait_to_resolv_or_connect
  resources
    接続中のfds
  do
    if 接続中のfdsがある
      if connect_timeout
        - タイムアウト済み -> timeout

      if 前回の接続のCONNECTION_ATTEMPT_DELAY中
        CONNECTION_ATTEMPT_DELAY # TODO ループとselectどちらでCONNECTION_ATTEMPT_DELAYするべきか考える
          - CONNECTION_ATTEMPT_DELAYタイムアウト -> v46wait_to_resolv_or_connectに戻る

      else if 前回の接続のCONNECTION_ATTEMPT_DELAYタイムアウト済み
        if IPv6 / IPv4アドレス解決中
          # TODO selectでCONNECTION_ATTEMPT_DELAYしても大丈夫?
          select([IPv4 fds, IPv?アドレス解決], CONNECTION_ATTEMPT_DELAY)
            - connectに成功                        -> success
            - IPv6 / IPv4アドレス解決              -> v46c
            - CONNECTION_ATTEMPT_DELAYタイムアウト -> v46wait_to_resolv_or_connectに戻る

        else if IPv6 / IPv4アドレス解決済み
          select([fds], CONNECTION_ATTEMPT_DELAY)
            - connectに成功                        -> success
            - CONNECTION_ATTEMPT_DELAYタイムアウト -> v46wait_to_resolv_or_connectに戻る

    else if 接続中のfdsがない
      - すべてのfdの接続に失敗 -> failure

case success
  resources
    接続済みのfd
    接続中のfdsがある可能性あり
  do
    cleanup
    return 接続済みfd

case failure
  resources
    なし
  do
    cleanup
    raise LastError

# 追加
case timeout
  resources
    connect_timeoutの場合、接続中のfds
  do
    cleanup
    raise TimeoutError
```

- v4c / v6cにおける「未解決のファミリがあり、未接続のaddrinfoの在庫が枯渇、すべてのfdが接続中」は
  impl14では`resolution_state[:ipv6_done] && resolution_state[:ipv4_done] && pickable_addrinfos.empty?`の場合
  それ以上アドレス解決を待たないようにすることによって永久に待機し続けるような事態を回避している
  - 最初にアドレス解決がなされて以降、`pickable_addrinfos`に解決済みのaddrinfoが勝手に入ってくるイメージ
