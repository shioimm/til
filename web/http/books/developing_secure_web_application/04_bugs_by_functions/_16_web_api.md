# 安全なWebアプリケーションの作り方(脆弱性が生まれる原理と対策の実践) まとめ
- 徳丸浩 著

## 16 Web API実装における脆弱性
- JSONはWeb APIで使用されるデータ形式としてXMLの代わりに使用されるようになった
- JSONP(JSON with Padding)
  - CORS以前に考案された異なるオリジンのサーバーからデータを取得する方法
  - XMLHttpRequestではなくscript要素を用いて外部のJavaScriptを直接実行する
  - JSON文字列ををscript要素で受け取ることができるようにするために関数呼び出しでデータを生成する

### JSONエスケープの不備
- JSON文字列生成時のエスケープ処理に不備がある場合、意図しないJavaScriptがJSONデータに混入する場合がある
  - デコードに`eval`を使っている場合
  - JSONPを利用している場合
- 発生箇所: JSONやJSONPを出力するAPI
- 影響範囲: アプリケーション全体
- 影響の種類: ユーザーのブラウザ上でのJavaScript実行
- 影響度合い: 中〜大
- 利用者関与の範囲: 必要 -> リンクのクリック、罠サイトの閲覧
- 対策: JSON生成時に安全なライブラリ関数を使用する

#### 事例
- 文字列連結によってJSONデータを生成するようなサイトにおいて、
  JSON文字列にパーセントエンコーディングを行なった終了文字を渡され、
  任意のスクリプトを実行されてしまう

#### 原因
- JSON生成時に適切なエスケープ処理を行なっていない
- JSONの評価に`eval`やJSONPを用いている

#### 対策
- 文字列連結によるJSONデータ生成をやめ、信頼できるライブラリを用いてJSONを生成する
- `eval`を使用せず安全な方法でJSONをパースする

### JSON直接閲覧によるXSS
- APIが返すレスポンスデータを直接ブラウザに閲覧させることにより攻撃が可能になる場合がある
- 発生箇所: JSONを生成するAPI
- 影響範囲: アプリケーション全体
- 影響の種類: ユーザーのブラウザ上でのJavaScript実行、偽情報の表示
- 影響度合い: 中〜大
- 利用者関与の範囲: 必要 -> 罠サイトの閲覧、メール記載のURLのクリック、攻撃を受けたサイトの閲覧
- 対策: MIMEタイプを正しく設定する

#### 事例
- JSONを返すAPIにおいて、MIMEタイプの設定を怠っており、
  application/jsonではなくデフォルトのtext/htmlを返している場合、
  URLにJavaScriptを実行するための要素を渡され、
  任意のスクリプトを実行されてしまう
```
// srcが見つからずエラーが発生した時点でスクリプトが実行される
http://example.com/example.php?zip=<img+src=1+onerror=任意のスクリプト>
```

#### 原因
- MIMEタイプが間違っている
- X-Content-Type-Optionsヘッダが指定されていない

#### 対策
- MIMEタイプを正しく設定する
- `X-Content-Type-Options: nosniff`を設定する
- `<` `>`などをUnicodeエスケープする
  - 古いブラウザがX-Content-Type-Optionsに対応していないため
- CORS対応の機能だけから呼び出せるようにする(XMLHttpRequestなど)

### JSONPのコールバック関数名によるXSS
- 発生箇所: JSONPを生成するAPI
- 影響範囲: アプリケーション全体
- 影響の種類: ユーザーのブラウザ上でのJavaScript実行、偽情報の表示
- 影響度合い: 中〜大↲
- 利用者関与の範囲: 必要 -> 罠サイトの閲覧、メール記載のURLのクリック、攻撃を受けたサイトの閲覧
- 対策:
  - MIMEタイプを正しく設定する
  - コールバック関数を検証する

#### 事例
- JSONPを返すAPIにおいて、Content-Typeヘッダの設定を怠っており、
  text/javascriptではなくデフォルトのtext/htmlを返している場合、
  URLにJavaScriptを実行するため要素を渡され、
  任意のスクリプトを実行されてしまう
```
// レスポンスボディが<script>任意のスクリプト</script>の形式となり、レスポンス時に実行されてしまう
http://example.com/example.php?callback=%3C/script%3E任意のスクリプト%3C/script%3E
```
#### 原因
- 外部から渡されたコールバック関数名を検証せずにそのまま表示している
- MIMEタイプが間違っている

#### 対策
- コールバック関数名の文字種と文字数を制限する
  - 渡すことができる文字列を英数字と`_`に限定する
- MIMEタイプを正しく設定する

### Web APIのCSRF
- GETリクエストによる攻撃
  - GETで副作用のある処理を行っているようなサイトにおいて、クエリ文字列によってCSRF攻撃を行われてしまう
- HTMLフォーム/CORS対応のXMLHttpRequestによる攻撃
  - 以下のHTTPリクエストに対してMINEタイプを許容している場合
    - text/plain
    - application/x-www-form-urlencoded
    - multipart/form-data

#### 対策
- CSRFトークン
- 二重送信クッキー
- カスタムリクエストヘッダ

### JSONハイジャック
- 発生箇所: JSONを出力するAPIで秘密情報を提供しているもの
- 影響範囲: JSONハイジャック脆弱性のあるAPI
- 影響の種類: なりすまし
- 影響度合い: 中〜大
- 利用者関与の範囲: 必要 -> リンクのクリック、罠サイトの閲覧
- 対策:
  - `X-Content-Type-Options: nosniff`を設定する
  - `X-Requested-With: XMLHttpRequest`リクエストヘッダの確認
- ブラウザ側の対策が進んでいるが、アプリケーション側でも対策を行うことが推奨される

### JSONPの不適切な利用
- JSONPにはCORSのようなアクセス制御の仕組みがない
  - JSONPによる情報公開は公開情報に限定する
  - JSONPをやめ、XMLHttpRequestを用いてCORSによるアクセス制御を行う

### CORSの検証不備
- オリジンとして`*`を指定する
  - `*` -> オリジンを制限しない
    - 公開情報を提供する場合などのみに使用する
- オリジンのチェックを緩和してしまう
  - Access-Control-Allow-Originヘッダにオリジンを指定することを怠らない

### セキュリティを強化するレスポンスヘッダ
- X-Frame-Options
- X-Content-Type-Options
- X-XSS-Protection
- Content-Security-Policy
- Strict-Transport-Security
