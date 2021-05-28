# TLS拡張
- プロトコル自体を修正することなくTLSに機能を追加する仕組み

## 代表的な拡張
| 拡張名                                   | 機能                     |
| -                                        | -                        |
| `application_layer_protocol_negotiation` | ALPN                     |
| `signed_certificate_timestamp`           | SCT転送                  |
| `elliptic_curves` / `ec_point_formats`   | 楕円曲線の利用可能性     |
| `server_name`                            | SNI                      |
| `renegotiation_info`                     | 安全な再ネゴシエーション |
| `session_ticket`                         | セッションチケット       |
| `signature_algorithms`                   | 署名アルゴリズム         |

## 拡張ブロック
- ClientHelloおよびServerHello のあとに配置される

```c
struct {
  ExtensionType extension_type; // 拡張タイプ
  opaque        extension_data; // 拡張のためのデータ
} Extension;
```

## ALPN(Application-Layer Protocol Negotiation)
- TLS接続上でアプリケーション層に異なるプロトコルを使うことをネゴシエーションするための拡張
  - `application_layer_protocol_negotiation`拡張によって実装される
- 443番ポートでデフォルトではHTTP/1.xを受け入れつつ、他のプロトコルのネゴシエーションを可能にする
- ALPNの送信には平文が使われ、経路上ののネットワーク機器が中身の情報に基づきトラフィックを経路制御する

### フロー
1. クライアント -> サーバー
    - ClientHelloメッセージにProtocolNameListフィールドを付加して送信する
    - ProtocolNameList - サポートするアプリケーションプロトコルのリスト
2. サーバー -> クライアント
    - ProtocolNameListを検証し、ServerHelloメッセージにProtocolNameフィールドを付加して送信する
    - ProtocolName - 選択したプロトコル

## SCT転送
- 公開ログサーバーに対してCAが自身の証明書を登録し、
  ログサーバーはSCT(Signed Certificate Timestamp: 署名済み証明書のタイムスタンプ)を返送し、
  最終的に末端の利用者が使っているツール上でSCTを検証することで
  サーバー証明書の透明性を担保する
- 公開ログサーバーからのSCT転送は`signed_certificate_timestamp`拡張によって実装される
  - 別の方法を利用する場合もある

## 楕円曲線の利用可能性
- クライアントで利用可能な楕円曲線について、クライアントが対応している楕円曲線の名前をClientHelloでリスト化する拡張
  - `elliptic_curves`によって実装される
- 楕円曲線上の点を圧縮するオプションをネゴシエーションするTLS拡張
  - `ec_point_formats`によって実装される

## 安全な再ネゴシエーション
- 過去にハンドシェイクを確立した二者間で再ネゴシエーションが実行されていることを検証してTLSの安全性を高める拡張
  - `renegotiation_info`によって実装される
- 双方のピアが安全な再ネゴシエーションに対応している場合、ハンドシェイク時に双方がこの拡張を利用する
- 以降のハンドシェイクで、クライアントは以前のハンドシェイクのFinished メッセージの`verify_data`を送信する
  サーバーはクライアントの`verify_data`および自分自身の`verify_data`を送信する

## SNI(Server Name Indication)
- 接続したいサーバーをクライアントが指定できるようにする拡張
  - `server_name`拡張によって実装される
- 一つのホストが複数のドメイン名を持つ時、ドメイン単位でサーバー証明書を利用することができる

### フロー
1. クライアント -> サーバー
    - ハンドシェイクの開始時、接続するホスト名を提示する
2. サーバー -> クライアント
    - 提示されたホスト名を検証し、適切な証明書を選び、ハンドシェイクを続行する

## セッションチケット
- サーバー側でセッションに関する情報を保持せずにセッションを再開できるようにする拡張
  - `session_ticket`拡張によって実装される
- サーバーがセッションデータを取得・暗号化し、特別なチケット鍵と一緒にチケットとしてクライアントに送り返す
  以降の接続でクライアントは拡張の中にチケットを格納してサーバーに送り返す
  サーバーはチケットの完全性を確認し、中身を復号してその中の情報を用いてセッションを再開する

## 署名アルゴリズム
- クライアントからサーバーに対して、対応している署名アルゴリズムとハッシュ関数の組みを伝える拡張
  - `signature_algorithms`拡張によって実装される

## OCSPステープル
- クライアントからサーバーに対して、クライアントがOCSPステープリングに対応していることを伝える拡張
  - `status_request`拡張によって実装される

## 参照
- ハイパフォーマンスブラウザネットワーキング
- 食べる！SSL！　―HTTPS環境構築から始めるSSL入門
- プロフェッショナルSSL/TLS
