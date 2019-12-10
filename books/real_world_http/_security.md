# Real World HTTP 歴史とコードに学ぶインターネットとウェブ技術 まとめ
- 渋川よしき 著

## セキュリティ
### OSを狙った攻撃
- マルウェア -> ユーザーの起動によって実行される
  - コンピュータウィルス
    - 実行ファイルを書き換え、他のプログラムにも自己を複製して増える
  - ワーム
    - OSの起動スクリプトなどに自己を登録し、セキュリティホールを攻撃して感染を広げる

#### 攻撃の例
- 設定を書き換える
- 外部からの遠隔操作を受け付けるバックドアを設定する
- DDoSの踏み台にする

### ブラウザを狙った攻撃
```
- トークン = サーバーとブラウザの関係を一意に決めるもの
- Cookie = トークンを格納する仕組み
```

#### クロスサイトスクリプティング
- Webサイトが意図しないスクリプトを実行させてしまう
- 例: 掲示板など
  - ユーザーがサイトへの投稿に意味のあるJSスクリプトを埋め込んだ場合、
  第三者がWebサイトを閲覧した際にブラウザがスクリプトを実行してしまう
- 対策:
  - 投稿内容をサニタイズしHTMLとして表示させる
  - Set-CookieヘッダーHttpOnly属性を付与しJSのDocument.cookieAPIからのアクセスを防ぐ
  - [X-XSS-Protection](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/X-XSS-Protection)ヘッダーを設定しXSS検出時にページの読み込みを停止する
  - [CSP](https://developer.mozilla.org/ja/docs/Web/HTTP/CSP)ヘッダーを設定しWebサイトで使用できる機能を細かく制御する
  - HTTP素材とHTTPS素材が同じページに混合している場合の処置を考える
  - [CORS](https://developer.mozilla.org/ja/docs/Web/HTTP/CORS)設定により細かく動作を制御する

#### 中間者攻撃
- プロキシサーバーが通信を中継する際に通信内容を抜き取られる
- 例:
  - フリーWiFi等で悪意のあるアクセスポイントを使用する
- 対策:
  - HTTPSを利用して通信内容を隠す
  - [HSTS](https://developer.mozilla.org/ja/docs/Glossary/HSTS)ヘッダーを設定しWebサイトからブラウザに対してHTTPSでの接続を促す
    - ブラウザはHSTSヘッダーを送信したURLをDBに保存する
  - [HTTP鍵ピンニング](https://developer.mozilla.org/ja/docs/Web/Security/Public_Key_Pinning)を利用する
    - サーバーから[Public-Key-Pins](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Public-Key-Pins)ヘッダーを設定し公開鍵のリストをクライアントに送信する
    - クライアントは2回目以降のアクセス時にピン留めした公開鍵のリストとサーバーが送った公開鍵のリストを比較し、証明書の改ざんが行われていないことを確認する

#### セッションハイジャッキング
WIP

#### クロスサイトリクエストフォージェリ
WIP

#### クリックジャッキング
WIP

#### リスト型アカウントハッキング
WIP

### Web広告
WIP
