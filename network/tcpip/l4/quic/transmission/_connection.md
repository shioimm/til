# QUICコネクション
- QUICの通信単位

## コネクションの確立 (1-RTTハンドシェイク)
1. クライアント -> サーバー: Initialパケットの送信
    - `CRYPTO`フレーム [ClientHello]
2. クライアント <- サーバー: Handshakeパケットの送信
    - `CRYPTO`フレーム [ServerHello]
    - `CRYPTO`フレーム [EncryptedExtensions, Certificate, Certificateverify, Finished]
3. クライアント -> サーバー: Handshakeパケットの送信
    - `CRYPTO`フレーム [Finished] - クライアント側としてQUICコネクションの確立が完了
4. クライアント -> サーバー: 1-RTTパケットの送信
    - `STREAM`フレーム - アプリケーションデータの送信を開始
5. クライアント <- サーバー: Handshakeパケットの送信
    - `HANDSHAKE_DONE`フレーム - サーバー側としてQUICコネクションの確立が完了
6. クライアント <- サーバー: 1-RTTパケットの送信
    - `STREAM`フレーム - アプリケーションデータの送信を開始

### トランスポートパラメータ(`quic_transport_parameters`)
- 通信に関するパラメータ
- ハンドシェイク時にTLS拡張 (TLSハンドシェイクメッセージに付随するデータ) として送信される

#### パラメータの内容 (一部)

| パラメータ                 | 意味                                     |
| -                          | -                                        |
| `max_idle_timeout`         | 最大アイドル時間                         |
| `stateless_reset_token`    | ステートレスリセット用トークン           |
| `max_ack_delay`            | Ackを送るまでの最大遅延時間              |
| `initial_max_streams_bidi` | オープンできる双方向ストリーム数の初期値 |
| `initial_max_streams_uni`  | オープンできる単方向ストリーム数の初期値 |

### プロトコルアップグレード
- QUICコネクションの際、
  クライアントはClientHello、サーバーはEncryptedExtensionsに`alpn={"h3"}`拡張を追加し
  メッセージとして送信し合うことによりHTTP/3の使用を決定する

## コネクションクローズ
- QUICコネクション上の通信を終了し、QUICコネクションに関する情報を破棄する

### コネクションクローズの種類
- アイドルタイムアウト
  - 事前に設定した一定時間以上相手から通信がない場合、自動的にクローズ
- 即時クローズ
  - `CONNECTION_CLOSE`フレームを送信することで即時にクローズ
  - QUICコネクション、アプリケーションプロトコルでエラーが発生した場合に使用する
- ステートレスリセット
  - 切断用トークンをサーバー <-> クライアント間でやりとりすることによってクローズ
  - QUICコネクション確立後、切断用のトークンをサーバーからクライアントへトークンを払い出し、
    クライアントがサーバーへトークンを送り返す
  - どちらかのエンドポイントが暗号化の鍵を喪失し状態が失われた場合などに使用する

## コネクションマイグレーション
- コネクションを切断することなくクライアントから自発的に通信経路を切り替える機能
  - e.g. キャリア回線 <-> Wi-Fi 回線

#### コネクションマイグレーションの確立
1. クライアント -> サーバー
    - `PATH_CHALLENGE`フレーム
2. クライアント <- サーバー
    - `PATH_RESPONSE`フレーム
3. 新しい経路で通信できることを確認できたら通信を開始し、古い経路の通信を中止する
    - 通信回線に依存する輻輳制御の状態などはリセットされる
    - 新しいコネクションIDを払い出す

## 参照
- WEB+DB PRESS Vol.123 HTTP/3入門