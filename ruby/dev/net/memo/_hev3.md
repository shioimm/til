# Happy Eyeballs Version 3 (HEv3)
## 現状のプロトコルネゴシエーション (socket -> net/http)
ruby/dev/net/memo/_protocol_negotiation.md に対して

1. ~~接続先についてDNS問い合わせ~~
2. 接続先とTCPで接続確立
    - Happy Eyeballs Version 2
3. 接続先へTLSハンドシェイク (ClientHello) ~~、ALPNで`h2, http/1.1`を通知する~~
4. 接続先からServerHelloとALPNで選択されたプロトコルが返ってくる
5. 接続先とTLSで接続確立 (~~htTP/2もしくは~~HTTP/1.1)
6. 接続先へHTTPリクエスト
7. 接続先からレスポンス
    - ~~レスポンスヘッダにAlt-Svcが含まれていた場合:~~
      - ~~クライアント - 接続先間でQUICハンドシェイク、TLS暗号交渉のうえHTTP/3セッション確立~~
