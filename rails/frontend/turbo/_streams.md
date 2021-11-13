# Turbo Streams
- リンク、フォーム送信以外の方法で特定のDOMを操作する機能を提供するライブラリ
  - append / prepend / replace / update / remove
- ActionCable用のヘルパーメソッドが提供されている
  - Turbo Streams用チャンネルのsubcribe、broadcastができる

#### Turbo StreamsによるDOM操作が発生するきっかけ
- フォーム送信などでTurboが扱ったHTTPレスポンスのMIME TypeがTurbo streams用のものだった場合
- Turbo Streamsに接続されたsourceがメッセージを受け取った場合
  - WebSocket / Sever Sent Events / Web Pushを使ったsourceなど

#### Turbo Framesへの補完
- DOM操作が発生するタイミングやDOM操作自体をより柔軟に行えるようにする

## 参照
- [クライアント側のJavaScriptを最小限にするHotwire](https://logmi.jp/tech/articles/324219)
- [まるでフロントエンドの"Rails" Hotwireを使ってJavaScriptの量を最低限に](https://logmi.jp/tech/articles/324253)
- [Hotwireとは何なのか？](https://zenn.dev/en30/articles/2e8e0c55c128e0)
