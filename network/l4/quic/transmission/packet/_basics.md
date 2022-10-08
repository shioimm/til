# QUICパケット
- QUICコネクションにおけるデータの送信単位
- QUICパケットはヘッダ領域とペイロード領域を持つ
  - ヘッダ (コネクションID、パケット番号etc)
  - ペイロード (QUICフレーム: フレームタイプetc)

#### パケット番号
- 送信者が採番し、受信者がパケットロスなどの判断を行うために確認する

## ロングヘッダパケット
- QUICコネクション確立時に使用されるパケット
- ヘッダにQUICのバージョン、送信元コネクションID・送信先コネクションIDを格納

```
Long Header Packet {
  Header Form (1) = 1, // 先頭ビットが0 = ロングヘッダパケット
  Fixed Bit (1) = 1,
  Long Packet Type (2),
  Type-Specific Bits (4),
  Version (32),
  Destination Connection ID Length (8), // 送信先コネクションID長
  Destination Connection ID (0..160), // 送信先コネクションID
  Source Connection ID Length (8), // 送信元コネクションID長
  Source Connection ID (0..160), // 送信元コネクションID
  Type-Specific Payload (..), // 種類別ペイロード
}
```

#### ロングヘッダパケットのコネクションIDの役割
- QUICコネクション確立時のハンドシェイク時に利用される
  - サーバーは受信したパケットに対して応答する際、
    受信パケットの送信元コネクションIDを自身の送信パケットの送信先コネクションIDとする

### ロングヘッダパケットの種類

| 種類                | 用途                                                                             |
| -                   | -                                                                                |
| Initial             | ハンドシェイク時、Initial段階の情報を運ぶ                                        |
| Version Negotiation | クライアントの提案バージョンに応答できない場合、サーバーがバージョンの候補を返す |
| 0-RTT               | 0-RTTハンドシェイク時に使用される                                                |
| Handshake           | ハンドシェイク時、Handshake段階の情報を運ぶ                                      |
| Retry               | サーバーからクライアントへInitailパケットの再送を指示する                        |

## ショートヘッダパケット
- QUICコネクション確立後に使用されるパケット
- ヘッダにスピンビット、暗号鍵のフェーズ、送信先コネクションIDを格納

```
Short Header Packet {
  Header Form (1) = 0, // 先頭ビットが0 = ショートヘッダパケット
  Fixed Bit (1) = 1,
  Spin Bit (1),
  Reserved Bits (2),
  Key Phase (1),
  Packet Number Length (2),
  Destination Connection ID (0..160), // 送信先コネクションID
  Packet Number (8..32), // パケット番号
  Packet Payload (..), // ペイロード
}
```

#### スピンビット
- 通信経路上での通信の最適化を期待する場合、スピンビットを用いることによって
  経路上の観測者が通信の遅延を観測できるようになる
- エンドポイントが使用するかどうかを選択できる

#### 暗号鍵のフェーズ
- 鍵の更新を示す

### ショートヘッダパケットの種類

| 種類      | 用途                                                    |
| -         | -                                                       |
| 1-RTT     | 1-RTTハンドシェイク時に使用される                       |

## 参照
- WEB+DB PRESS Vol.123 HTTP/3入門
- [QUICをゆっくり解説(3)：QUICパケットの構造](https://eng-blog.iij.ad.jp/archives/10539)
