# 通信種別
- ユニキャスト - 1:1通信
- マルチキャスト - 複数ノードへ一斉同報
- ブロードキャスト - 特定ネットワーク内の全ノードへ一斉同報(動画配信や証券取引系アプリケーション)
- エニーキャスト - 同じIPアドレスを持つ複数ノードへ一斉同報

| 種類             | 送信先:宛先比                    | 送信元MACアドレス       | 宛先MACアドレス       |
| -                | -                                | -                       | -                     |
| ユニキャスト     | 1:1                              | 送信元端末のMACアドレス | 宛先端末のMACアドレス |
| ブロードキャスト | 1:n (同じEthernetネットワーク上) | 送信元端末のMACアドレス | ff-ff-ff-ff-ff        |
| マルチキャスト   | 1:n (特定グループ)               | 送信元端末のMACアドレス | 宛先端末のMACアドレス |
