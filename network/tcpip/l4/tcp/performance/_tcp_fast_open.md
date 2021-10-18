## TCP Fast Open
- SYNパケット内でのデータ転送を許可することによってTCP接続開始の際のレイテンシを軽減する
- 短いTCP通信におけるハンドシェイクのコストを下げる

#### 仕組み
1. クライアント -> サーバー: SYNにFast Open Cookie Requestをつけて送信する
2. サーバー -> クライアント: SYN・ACK時にTCPオプションの34番でTFO Cookieを返す
3. クライアント -> サーバー: ACKを返し接続確立を終える・TFO Cookieをキャッシュする
4. クライアント -> サーバー: リクエストにTFO Cookieをつけて送信する
5. サーバー -> クライアント: TFO Cookieが正しいIPであればクライアントからのACK受信前にレスポンスを送信する
6. 以降繰り返し

## 参照
- [TCP FAST OPENとは？](https://blog.redbox.ne.jp/tcp-fast-open-cdn.html)
- ハイパフォーマンスブラウザネットワーキング
