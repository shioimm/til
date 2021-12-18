# TLS拡張
- プロトコル自体を修正することなくTLSに機能を追加する仕組み
- ClientHelloおよびServerHelloメッセージの後に
  拡張ブロックの形で個々の拡張が必要な数だけ順番に配置される

```c
struct {
  ExtensionType extension_type; // 拡張タイプ (識別子)
  opaque extension_data; // 拡張データ
} Extension;

Extension extensions;
```

## 代表的な拡張
| 拡張名                                   | 機能                        |
| -                                        | -                           |
| `application_layer_protocol_negotiation` | ALPN                        |
| `heartbeat`                              | Heartbeatプロトコルへの対応 |
| `signed_certificate_timestamp`           | SCT転送                     |
| `elliptic_curves` / `ec_point_formats`   | 楕円曲線の利用可能性        |
| `server_name`                            | SNI                         |
| `renegotiation_info`                     | 安全な再ネゴシエーション    |
| `session_ticket`                         | セッションチケット          |
| `signature_algorithms`                   | 署名アルゴリズム            |

#### `application_layer_protocol_negotiation`拡張
- TLS接続上でアプリケーション層に異なるプロトコルを使うことをネゴシエーションする
  ALPN (Application-Layer Protocol Negotiation) のための拡張
- 443番ポートでデフォルトではHTTP/1.xを受け入れつつ、他のプロトコルのネゴシエーションを可能にする
- 主要な機能はNPN (Next Protocol Negotiation) と拡張と同じ
  - NPNではプロトコルの決定を暗号化によって隠蔽している
  - ALPNではプロトコルの決定を平文で行い、経路上のネットワーク機器が中身の情報に基づき
    トラフィックを経路制御する

#### ALPNの動作フロー
1. クライアント -> サーバー
    - ClientHelloメッセージにProtocolNameListフィールドを付加して送信する
    - ProtocolNameList - サポートするアプリケーションプロトコルのリスト
2. クライアント <- サーバー
    - ProtocolNameListを検証し、ServerHelloメッセージにProtocolNameフィールドを付加して送信する
    - ProtocolName - 選択したプロトコル

#### `signed_certificate_timestamp`拡張
- CT (Certificate Transparency: 証明書の透明性) は公開のログサーバーに対して
  CAが自身の証明書を登録することでサーバー証明書の透明性を担保する仕組み
- ログサーバーはSCT (Signed Certificate Timestamp: 署名済み証明書のタイムスタンプ) をCAに返送し、
  最終的には末端の利用者が使っているツール上でSCTの検証が行われる
- `signed_certificate_timestamp`TLS拡張を利用してSCTの転送を行う

#### `elliptic_curves`拡張
- クライアントで利用可能な楕円曲線について、
  クライアントが対応している楕円曲線の名前をClientHelloでリスト化する拡張

#### `ec_point_formats`拡張
- クライアントで利用可能な楕円曲線について、
  楕円曲線上の点を圧縮するオプションをネゴシエーションするTLS拡張
  - 楕円曲線上の点の圧縮によって帯域幅を節約することができる

#### `heartbeat`拡張
- Keep-Alive (やり取りしている相手の死活を確かめる) およびパスMTU (PMTU、PathMTU) 探索機能を
  TLSとDTLSで提供するためのプロトコル拡張
  - TCPのKeep-Aliveとは別にDTLS (トランスポート層の信頼性を提供しないプロトコル、UDPなど) を対象とする
- 2014年4月にOpenSSLのHeartbeatの実装に脆弱性が見つかった (Heartbleed攻撃脆弱性)

#### `renegotiation_info`拡張
- 過去にハンドシェイクを確立した二者間で再ネゴシエーションが実行されていることを検証し、
  TLSの安全性を高める拡張
- 双方のピアが安全な再ネゴシエーションに対応している場合、ハンドシェイク時に双方がこの拡張を利用する
- 以降のハンドシェイクで、クライアントは以前のハンドシェイクのFinished メッセージの`verify_data`を送信する
  サーバーはクライアントの`verify_data`および自分自身の`verify_data`を送信する

#### `server_name`拡張
- SNI (Server Name Indication) は接続したいサーバの名前をクライアントが指定できるようにする仕組み
- クライアントは`server_name`拡張を利用し、ClientHelloの中に接続したいサーバーの名前を記述する
  - ホストに対してバーチャルホストのドメイン名を指定するために利用される
  - `server_name`拡張によって実装される
- SNIを暗号化する規格はESNI (Encrypted SNI)
  - ECHはClientHello自体を暗号化する

#### SNIの動作フロー
1. クライアント -> サーバー
    - ハンドシェイクの開始時、接続するホスト名を提示する
2. クライアント <- サーバー
    - 提示されたホスト名を検証し、適切な証明書を選び、ハンドシェイクを続行する

#### `session_ticket`拡張
- サーバー側でセッションに関する情報を保持せずにセッションを再開できるようにする拡張
- サーバーがセッションデータを取得・暗号化し、特別なチケット鍵と一緒にチケットとしてクライアントに送り返す
  以降の接続でクライアントは拡張の中にチケットを格納してサーバーに送り返す
  サーバーはチケットの真正性を確認し、中身を復号してその中の情報を用いてセッションを再開する

#### `signature_algorithms`拡張
- クライアントからサーバーに対して、対応している署名アルゴリズムとハッシュ関数の組みを伝える拡張
- 拡張がない場合、サーバーはクライアントが提案した暗号スイートをもとに
  クライアントが対応している署名アルゴリズムを推察する

## `status_request`拡張
- クライアントからサーバーに対して、クライアントがOCSPステープリングに対応していることを伝える拡張
- `status_request`拡張に応答するサーバーはServerHelloに`status_request`拡張を格納して返答し
  Certificateメッセージ直後のCertificateStatusメッセージでOCSPレスポンスを提示する

## 参照
- ハイパフォーマンスブラウザネットワーキング
- 食べる！SSL！　―HTTPS環境構築から始めるSSL入門
- プロフェッショナルSSL/TLS
