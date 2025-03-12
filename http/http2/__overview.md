# HTTP/2
- HTTP/1.1のセマンティクスを変更せず、より効率よくHTTPメッセージを送信するためのプロトコル
- 一本のTCP接続の内部に仮想のTCPソケット(ストリーム)を作成し通信を行う

#### 目的
- Webページのリソースの増加(数、サイズ)に伴うパフォーマンス改善
  - リクエストとレスポンスの多重化によるレイテンシの低減
  - HTTPヘッダフィールドの効率的な圧縮によるプロトコルのオーバーヘッド最小化
  - リクエストの優先順位付けとサーバプッシュ機能の追加
- 「HTTPメッセージのセマンティクスを維持し、パフォーマンスとセキュリティを改善する」

#### SPDY
- Googleで開発されたHTTP/2の基盤となるプロトコル

#### HTTP/1.1の課題
- リクエストの処理数がTCPの数に依存している
- Webページが必要とするリソースの数だけリクエストが必要
- ヘッダーのデータサイズの大きさ

#### HTTP/2の改善点
- バイナリフレームレイヤーの導入
  - ストリーム(HTTP/1.1のパイプライニングに近い)を使用してバイナリデータを多重に送受信する
  - 並列処理のために複数TCP接続が不要になった
- ストリーム内での優先順位設定を実装
- サーバーサイドからデータ通信を行うサーバープッシュ機能を実装
- ヘッダが圧縮されるようになった

#### Key feature
- binary protocol
- header compression
- multiplexing
- prioritization

#### ポート番号(変更なし)
- http - 80
- https - 443

#### 識別子
- どのような方式で接続を行うかを決めるためのもの
  - h2(HTTP/2 over TLS -> いわゆるhttps)
  - h2c(HTTP/2 over TCP -> いわゆるhttp)

#### TLS
- HTTP/2は規格上TLSによる暗号化は不要
  - ただし実際にはほとんどのクライアントがh2c未対応
- TLS1.2以上のバージョンが必要

## ストリーム・メッセージ・フレーム
- HTTP/2通信は、任意の数の双方向ストリームを流すことができる単一のTCPコネクション上で行われる
- 各ストリームはメッセージ単位で通信を行い、各メッセージは一つ以上のフレームで構成され、
  各フレームはコネクション上にインターリーブされ、ヘッダ内のストリームIDに従って宛先で再構成される
  - ストリーム - 確立したコネクション内の仮想チャネル
  - メッセージ - 1つ以上のフレームで構成される論理的なHTTPメッセージ
  - フレーム - HTTP/2における通信の最小単位

## 接続方法
### (1) ALPN識別子
- https接続を行う場合
- TLSハンドシェイク時にネゴシエーションを実施する
```
1. Client-Hello時、ALPN extensionにクライアントが対応しているプロトコルのリストを付加して送信
2. Server-Hello、サーバーが対応しているプロトコルを選択してALPN extensionで送信
3. ネゴシエーション完了
```

### (2) プロトコルアップグレード
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

### (3) ダイレクト
- http接続を行う場合
- サーバーがHTTP/2に対応していることがわかっている場合(以前接続済みの場合など)は
  クライアントからネゴシエーションを行わずダイレクトにHTTP/2接続を行なっても良い

## Webサーバーの構成
#### HTTP/2を直接受ける
```
クライアント -> HTTP/2 -> サーバー
```

#### HTTP/2をリバースプロキシする
```
クライアント -> HTTP/2 -> プロキシサーバー -> HTTP/2 -> バックエンドサーバー
クライアント -> HTTP/2 -> プロキシサーバー -> HTTP/1 -> バックエンドサーバー
```

#### TLSの終端のみ行う
```
クライアント -> HTTP/2 over TLS -> TLS終端サーバー -> HTTP/2 -> バックエンドサーバー
```

## 参照
- [普及が進む「HTTP/2」の仕組みとメリットとは](https://knowledge.sakura.ad.jp/7734/)
- [HTTP の進化](https://developer.mozilla.org/ja/docs/Web/HTTP/Basics_of_HTTP/Evolution_of_HTTP)
- [そろそろ知っておきたいHTTP/2の話](https://qiita.com/mogamin3/items/7698ee3336c70a482843)
- [Request and Response](https://youtu.be/0cmXVXMdbs8)
- [HTTP/2 Server Pushとは？(CDN サーバープッシュでWeb高速化）](https://blog.redbox.ne.jp/http2-server-push-cdn.html)
- [HTTP/2とは](https://www.nic.ad.jp/ja/newsletter/No68/0800.html)
- [HTTP/2](https://hpbn.co/http2/#binary-framing-layer)
- よくわかるHTTP/2の教科書P76-78
- [【招待講演】最速ウェブサーバの作り方　奥 一穂氏](https://www.youtube.com/watch?v=Iu5Uynq7ubo&feature=youtu.be)
- Real World HTTP 第2版
- ハイパフォーマンスブラウザネットワーキング
