# コネクション
- 参照: [普及が進む「HTTP/2」の仕組みとメリットとは](https://knowledge.sakura.ad.jp/7734/)
- 参照: [HTTP の進化](https://developer.mozilla.org/ja/docs/Web/HTTP/Basics_of_HTTP/Evolution_of_HTTP)
- 参照: [そろそろ知っておきたいHTTP/2の話](https://qiita.com/mogamin3/items/7698ee3336c70a482843)
- 参照: [Request and Response](https://youtu.be/0cmXVXMdbs8)
- 参照: [HTTP/2とは](https://www.nic.ad.jp/ja/newsletter/No68/0800.html)
- 参照: [HTTP/2](https://hpbn.co/http2/#binary-framing-layer)
- 参照: よくわかるHTTP/2の教科書P76-126

## コネクションの接続
- HTTP/2はHTTP/1.xと同じTCPポートを利用して接続を行う
- クライアント -> サーバーへHTTP/2での通信開始をネゴシエーションする
- ネゴシエーション後、クライアント-サーバー間で最終的な接続確認(コネクションプリフェイス)を行なった後
  HTTP/2通信に移行する

### 接続方法(1) ALPN識別子
- https接続を行う場合
- TLSハンドシェイク時にネゴシエーションを実施する
```
1. Client-Hello時、ALPN extensionにクライアントが対応しているプロトコルのリストを付加して送信
2. Server-Hello、サーバーが対応しているプロトコルを選択してALPN extensionで送信
3. ネゴシエーション完了
```

### 接続方法(2) アップグレード
- http接続を行う場合
- HTTP/1.1で接続を行なった後、HTTP/2へ切り替えする
```
1. クライアントがHTTP/1.1で通信開始時、以下のリクエストヘッダを送信
   - Connectionヘッダ: UpgradeとHTTP2-Settings
   - Upgradeヘッダ: h2c
   - Http2-Settingsヘッダ: base64urlエンコードしたHTTP/2のSettingsフレームのペイロード
2. サーバーが対応していた場合、ステータスコード101のレスポンスを返し、
   HTTP/2コネクションに移行
```

### 接続方法(3) ダイレクト
- http接続を行う場合
- サーバーがHTTP/2に対応していることがわかっている場合(以前接続済みの場合など)は
  クライアントからネゴシエーションを行わずダイレクトにHTTP/2接続を行なっても良い

### コネクションプリフェイス
- クライアントコネクションプリフェイス
  - 末尾が'\r\n'で終わる16進数の固定値
  - SETTINGSフレーム
- サーバーコネクションプリフェイス
  - SETTINGSフレーム

## コネクションの再利用
- [HTTPの場合]ドメイン名のIPアドレスが同じ場合再利用可
- [HTTPSの場合]ドメイン名のIPアドレスが同じであり、 証明書が有効である場合再利用化
