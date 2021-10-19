# TCP Fast Open (TFO)
- TCP接続開始の際のレイテンシを軽減するメカニズム
- 3Wayハンドシェイク中、SYN・SYN /ACKパケットにアプリケーションデータを乗せることによって実現する
- クライアント・サーバー両者がTFOを有効化しておく必要がある

#### 仕組み
1. クライアント
    - サーバーへFast Open Cookie Requestを送信
      (SYNパケットにTCPオプションとしてFast Open Cookie Requestをセットして送信する)
    - Fast Open CookieはTFOのセキュリティを確保する目的で使用される
2. サーバー
    - クライアントからFast Open Cookie Request付きのSYNパケットを受信
    - クライアントのIPアドレスからFast Open Cookieを生成
    - TCPオプションとしてFast Open CookieをセットしたSYN / ACKパケットをクライアントへ送信
3. クライアント
    - サーバーからFast Open Cookie付きのSYN / ACKパケットを受信
    - TFO Cookieをキャッシュする
    - サーバーへACKパケットを送信(接続確立・コネクション終了)
4. クライアント (2回目以降のリクエスト)
    - TCPオプションにTFO Cookie、TCPペイロードにリクエストをセットしてサーバーへSYNパケットを送信
5. サーバー
    - クライアントからTFO Cookie付きのSYNパケットを受信
    - TFO Cookieの真正性を確認
    - TFO Cookieが正しければクライアントへレスポンスデータと共にSYN / ACKパケットを送信
    - TFO Cookieの有効期限が切れた場合は3wayハンドシェイクからやり直し

## 参照
- [TCP FAST OPENとは？](https://blog.redbox.ne.jp/tcp-fast-open-cdn.html)
- ハイパフォーマンスブラウザネットワーキング
- パケットキャプチャの教科書
