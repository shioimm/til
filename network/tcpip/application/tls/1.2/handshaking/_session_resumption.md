# セッションリザンプション
## セッションID方式
- ServerHello時にサーバーからクライアントへ送信される
  0～32バイトの一意なセッションIDを使うことによって
  前回のセッションを再開するしくみ
- クライアントとサーバーはフルハンドシェイクによって確立した接続の終了後、
  セッションID、`master_secret`、その他各種セッションパラメータ一式を
  各自セッションキャッシュ領域に保存する

#### 動作フロー
1. クライアント <- サーバー
    - HelloRequest (optional)
2. クライアント -> サーバー
    - ClientHello
3. クライアント <- サーバー
    - ServerHello
    - ChangeCipherSpec
    - Finished
4. クライアント -> サーバー
    - ChangeCipherSpec
    - Finished

#### ClientHello (クライアント)
- セッションを再開する場合、ClientHelloメッセージにセッションIDを含めて送信

#### ServerHello (サーバー)
- 当該セッションを再開する場合、同じセッションIDをServerHelloメッセージに含めて送信

#### ChangeCipherSpec (サーバー)
- 以前共有したマスターシークレットを使って新しい暗号鍵 (暗号化に使う鍵やMAC鍵) を生成
- サーバー側で暗号通信に切り替え、その旨をクライアントに送信

#### Finished (サーバー)
- 送信および受信したハンドシェイクメッセージのMACを送信

#### ChangeCipherSpec (クライアント)
- 以前共有したマスターシークレットを使って新しい暗号鍵 (暗号化に使う鍵やMAC鍵) を生成
- クライアント側で暗号通信に切り替え、その旨をサーバーに送信

#### Finished (クライアント)
- 送信および受信したハンドシェイクメッセージのMACを送信

## セッションチケット方式
- ハンドシェイク終了後サーバーからクライアントへ送信される
  NewSessionTicketメッセージにて最大64kbのセッションチケットを使うことによって
  前回のセッションを再開するしくみ
  - サーバーはセッションパラメータそのものを暗号化し、セッションチケットとして発行する
- クライアントはフルハンドシェイクによって確立した接続の終了後、
  セッションチケットをClientHelloの`session_ticket`拡張に格納し送信する
- サーバーはクライアントから送信されたセッションチケットを解読し
  有効な内容であればセッションを再開する

#### 動作フロー
1. クライアント <- サーバー
    - HelloRequest (optional)
2. クライアント -> サーバー
    - ClientHello [`session_ticket`]
3. クライアント <- サーバー
    - ServerHello
    - NewSessionTicket
    - ChangeCipherSpec
    - Finished
4. クライアント -> サーバー
    - ChangeCipherSpec
    - Finished

## 参照
- プロフェッショナルSSL/TLS
- 暗号技術入門 第3版
- パケットキャプチャの教科書
- [TLS v1.3の仕組み ~Handshakeシーケンス,暗号スイートをパケットキャプチャで覗いてみる~](https://milestone-of-se.nesuke.com/nw-basic/tls/tls-version-1-3/)

