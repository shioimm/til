# Happy Eyeballs Version 3 (HEv3)
## 現状のプロトコルネゴシエーション (socket -> net/http)
ruby/dev/net/memo/_protocol_negotiation.md に対して

1. ~~接続先についてDNS問い合わせ~~
2. 接続先とTCPで接続確立
    - Happy Eyeballs Version 2
3. 接続先へTLSハンドシェイク (ClientHello) ~~、ALPNで`h2, http/1.1`を通知する~~
4. 接続先からServerHelloとALPNで選択されたプロトコルが返ってくる
5. 接続先とTLSで接続確立 (~~HTTP/2もしくは~~HTTP/1.1)
6. 接続先へHTTPリクエスト
7. 接続先からレスポンス
    - ~~レスポンスヘッダにAlt-Svcが含まれていた場合:~~
      - ~~クライアント - 接続先間でQUICハンドシェイク、TLS暗号交渉のうえHTTP/3セッション確立~~

## 追加で必要な能力
- クライアントのネットワークがIPv6-onlyもしくはIPv6-mostlyかどうかの判定
  - クライアントデバイスが464XLATに対応しているかどうかの判定
  - PREF64の取得
  - NAT64プレフィックスの検出
  - ローカルIPv6アドレス合成
- アドレスのグループ化と並び替え
  - SVCB/HTTPSレコードの問い合わせ
  - SVCBパラメータの解析、AliasMode / ServiceModeの判別、サービス優先度の取得
- 接続試行可能なエンドポイントの判定
  - SVCBのALPNセットとクライアントがサポートするプロトコルの照合
- SVCB応答が失敗した場合に接続試行をキャンセルするかどうかの判定
  - DNS応答が保護されているかどうかの判定
- 接続試行成功の判定
  - ハンドシェイク完了の検知
