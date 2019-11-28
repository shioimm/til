# Real World HTTP 歴史とコードに学ぶインターネットとウェブ技術 まとめ
- 渋川よしき 著

## HTTPの基本要素
- メソッドとパス
- ヘッダー
- ボディ
- ステータスコード

## ヘッダー
- `フィールド名:値`という形式で本文の前に付加される
- サーバー-クライアント間での追加情報、指示や命令、お願いなど

### リクエスト
#### [User-Agent](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/User-Agent)
- ブラウザ、OSなどのユーザーエージェント情報を識別する特性文字列

#### [Referer](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Referer)
- 現在のページにリクエストを送る前にリンクを踏んだ直前のページのアドレス

#### [Authorization](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Authorization)
- 特別なクライアントにだけ通信を許可する場合、ユーザーエージェントがサーバーから認証を受けるための証明書

### レスポンス
#### [Content-Type](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Content-Type)
- ファイルの種別を示す識別子(MINEタイプ)

#### [Content-Length](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Content-Length)
- サーバーから送信するボディのサイズ(バイト単位)

#### [Content-Encoding](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Content-Encoding)
- ボディが圧縮されている場合、その圧縮形式

#### [Date](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Date)
- メッセージが発信された日時

### その他
- `X-`から始まるヘッダーは各アプリケーションで自由に設定されたもの

## X-Powered-Byヘッダー
- サーバーがシステム名を返す際のヘッダー名であり、かつてのデファクトスタンダード
  - 現在はRFCで規定された[Serverヘッダー](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Server)を利用している

### コンテントネゴシエーション
- ヘッダーを利用してサーバーとクライアントがお互いにベストな設定を共有する仕組み

#### ネゴシエーションの対象
- MINEタイプ
  - リクエストヘッダー: Accept
  - レスポンスヘッダー: Content-Type
- 表示言語
  - リクエストヘッダー: Accept-Language
  - レスポンスヘッダー: Content-Type
- 文字のキャラクターセット
  - リクエストヘッダー: Accept-Charset
  - レスポンスヘッダー: Content-Type
- ボディの圧縮
  - リクエストヘッダー: Accept-Encoding
  - レスポンスヘッダー: Content-Encoding

### クッキー
- サーバー側のデータをクライアント側に保存させるための機構
- 名前=値の形式でヘッダーにてやり取りを行う
- 永続化されていないため、シークレットモードやブラウザ側の操作で削除される場合がある
- 容量は最大4KB
- HTTPSでは暗号化された場合にしか送信できないが、HTTPの場合は平文で送信される

#### クッキーの制約
- Expires / Max-Age属性
  - 有効期限(Max-Ageは秒単位)
- Domain属性
  - クライアントからクッキーを送信する対象のサーバー
    - デフォルトでクッキーを発行したサーバー
- Path属性
  - Domain属性のサーバーのパス
- Secure属性
  - https以外での通信を行わない
  - httpでの通信の場合に警告を発する
- HttpOnly属性
  - JavaScriptエンジンからクッキーを隠す
- SameSite属性
  - Chromeがバージョン51で導入した属性、同じオリジンのドメインに対して送信する

### キャッシュ機構
- 更新日時によるキャッシュ
  - リクエストに付与された日時とサーバー上のコンテンツの日時の比較
- Expiresヘッダーによるキャッシュ
  - 現在がリクエストヘッダーに付与された有効期限日時以前であることの確認
-  [Pragma: no-cache](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Pragma)(-> Cache-Control)
  - 「リクエストしたコンテンツがプロキシサーバーにキャッシュされている場合も、オリジンサーバーまでリクエストを届ける」という指示
-  [ETag](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/ETag)
  - サーバーがレスポンスに付与する「ファイルに関するハッシュ値」
  - クライアントは二回め以降のリクエストで、If-None-MatchヘッダーにてETagを送信する
  - サーバーはリクエストのETagの値とレスポンスするファイルのETagを比較
-  [Cache-Control](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Cache-Control)
  - リクエストヘッダーとレスポンスヘッダーのキャッシュ規則を指定する
- [Vary](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Vary)
  - 同じURLでもクライアントによって返す結果が異なる理由を列挙する
    - ユーザーエージェント、言語 etc

## メソッド
### [GET](https://developer.mozilla.org/ja/docs/Web/HTTP/Methods/GET)
- サーバーに対してヘッダーとコンテンツを要求

### [HEAD](https://developer.mozilla.org/ja/docs/Web/HTTP/Methods/HEAD)
- サーバーに対してヘッダーを要求

### [POST](https://developer.mozilla.org/ja/docs/Web/HTTP/Methods/POST)
- サーバーに対してデータを送信

### [PUT](https://developer.mozilla.org/ja/docs/Web/HTTP/Methods/PUT)
- すでにURLが存在するコンテンツの置き換え

### [DELETE](https://developer.mozilla.org/ja/docs/Web/HTTP/Methods/DELETE)
- コンテンツとURLの削除

### [OPTIONS](https://developer.mozilla.org/ja/docs/Web/HTTP/Methods/OPTIONS) -> HTTP/1.1で追加
- サーバーが受け取り可能なメソッド一覧を返す
- サーバー側で使用が許可されていない場合が多い

### [TRACE](https://developer.mozilla.org/ja/docs/Web/HTTP/Methods/TRACE) -> HTTP/1.1で追加
- サーバーが受け取るとContent-Typeにmessage/httpを設定し、ステータスコード200をつけてリクエストヘッダとボディを返す
- XST脆弱性により現在は使われていない

### [CONNECT](https://developer.mozilla.org/ja/docs/Web/HTTP/Methods/CONNECT) -> HTTP/1.1で追加
- HTTPのプロトコル上に他の他のプロトコルのパケットを流せるようにする
- プロキシサーバー経由でターゲットのサーバーに接続することを目的とする
- https通信を中継する用途で使われる

### 廃止されたメソッド
- LINK
- UNLINK
- CHECKOUT
- CHECKIN
- SHOWMETHOD
- TEXTSEARCH
- SEARCHJUMP
- SEARCH

## パス(URL)
```
https://www.oreilly.co.jp/index.shtml

# スキーマ://ホスト名/パス

# URLの全要素
# スキーマ://ユーザ:パスワード@ホスト名:ポート/パス#フラグメント?クエリ
```
- ポートはスキーマごとにデフォルト値を持つ(httpは80、httpsは443)
- URLの長さはだいたい2000文字くらい(IEは2083文字)

## ステータスコード
- 100番台 -> 処理中
- 200番台 -> 成功
- 300番台 -> サーバーからクライアントへの指示
  - リダイレクトなど -> リダイレクトはLocationヘッダを参照し、ヘッダごと送信し直す
- 400番台 -> クライアント側の異常
- 500番台 -> サーバー側の異常

## ボディ
- ヘッダーの下に空行を入れると、それ以降はボディとして扱われる
- 一通信につき、Content-Length分が指定するバイト数分の一ファイルを扱う

### フォーム
- POST以外のメソッドでボディ(フォーム)を送信することは推奨されない(サーバー側で受け付けない場合がある)
  - そのため、GETにてフォームを送信する場合は、ボディでは無くURLにクエリとして文字列を付与する

#### multipart/form-data
- フォームにてファイルを送信することができるエンコードタイプ
- Content-Typeにboundary(境界文字列・ブラウザごとに異なる)属性が加わる
- ボディ内にヘッダー + 空行 + コンテンツを構成する
  - ヘッダーにContent-Disposition(Content-Typeのようなもの)が加わる

## 認証とセッション
- BASIC認証
- Digest認証
- クッキーによるセッション管理
```
1. クライアントがフォームからIDとPASSを送信(通信時の暗号化が必須)
2. サーバーがIDをPASSを認証し、セッショントークンを発行
3. サーバーがセッショントークンをDBに保存
4. サーバーがクライアントに送信
```

- 署名つきクッキーによるセッション管理
```
1~3までは上記と同じ
4. サーバーがクライアントに対して電子署名済みのセッショントークンを発行
5. クライアントがクッキーを再送した際、サーバーが署名を確認
# サーバー側が署名・確認を行うため、クライアントは鍵を持たない
```

## プロキシ
- HTTPなどの通信を中継する仕組み
- 中継をする際に付加機能が実装される場合がある
  - キャッシュ機構
  - ファイアウォール
  - コンテンツフィルタ
  - 画像圧縮フィルタ etc
- プロキシサーバーを設定することでURL(パス)にスキーマが追加される
- X-Forwarded-Forヘッダーに中継プロキシが追加される

### ゲートウェイとの違い
- ゲートウェイ -> 通信内容をそのまま転送する
- プロキシ     -> コンテンツを改変したりサーバーの代わりに応答したりする

## ダウンロード
- レスポンスヘッダーに[Content-Disposition](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Content-Disposition)が含まれる場合、ブラウザは保存ダイアログを出しデータを保存する
- ダウンロードの中断が中断された場合、途中から再開する方法が提供されている
  - 途中から再開 = ファイルの指定範囲を切り出してダウンロードする
  - 指定範囲ダウンロードをサポートしているサーバーは次のヘッダーをレスポンスに付与する
    - [Accept-Ranges](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Accept-Ranges)ヘッダーをレスポンスに付与する
    - [ETag](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/ETag) -> コンテンツの変更を検知するため
  - ブラウザは[Range](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Range)ヘッダーをリクエストに与えて転送してほしい範囲を指定する
    - Rangeヘッダーは複数範囲の指定も可能
      - サーバーは`Content-Type: multipart/byteranges;`を返す
      - ダウンロード時間短縮のためRangeヘッダーを使用し並列ダウンロードを行うことは、サーバーに負荷をかけるため推奨されていない

## [XMLHttpRequest](https://developer.mozilla.org/ja/docs/Web/API/XMLHttpRequest)
- curlコマンドと同等の操作をJavaScriptから行うことができる機能
- ページ全体を更新せずにデータを受け取ることができるため、Ajaxプログラミングで使用される

### ブラウザのHTTPリクエストとの違い
- 送受信時にHTMLの画面がリロードされない
- GET / POST以外のメソッドも送信できる
- キーと値が一対一になっているデータ形式以外のフォーマットでデータを送信できる(プレーンテキスト、JSON、XMLetc)
- セキュリティのための制約を持つ

### Comet
- XMLHttpRequestを使用したレガシーなリアルタイム双方向通信
- ポーリング -> 通知を受ける側が、通知の有無を頻繁に訊きにいく方式
- ロングポーリング -> クライアントからサーバーにリクエストを送った後、即時にレスポンスを返さず保留する
サーバー側から通信を完了させるか、リクエストがタイムアウトした際にレスポンスを返す
- Cometはロングポーリングを使用している
- 一メッセージあたりのオーバーヘッドが大きくサーバーからの連続したメッセージに強くない
- Cometよりも後に、より応答性の良いサーバー通知の仕組みが作られた

### セキュリティ
- アクセスできる情報の制限
  - 例: Cookieの制限(CookieにhttpOnly属性を付与し、スクリプトからアクセスできないようにするなど)
- 送信制限
  - リクエストを送信できるドメインの制限(CORS)
  - 利用できるHTTPメソッドの制限
  - ヘッダーの制限
    - 例: プロトコルのルールや環境に影響を与えるもの、セキュリティに影響を与えるもの、ブラウザの能力を超えられないもの

## Geo-Location
- クライアントの物理的な場所を測定する

### クライアント自身が場所を得る
- ブラウザに実装されたGeolocation API
  - GPS
  - WiFiのアクセスポイント
- スマートフォンを利用したクラウドソーシング

### サーバーがクライアントの場所を得る
- GeoIP(IPアドレス)

## リモートプロシージャコール(RPC)
- プロシージャ = 関数、サブルーチン
- 別のコンピュータにある機能を自分のコンピュータ内であるかのように呼び出し、必要に応じて返り値を受け取る

### XML-RPC(1998年)
- POSTメソッドで通信し、呼び出しの引数・返り値をXMLで表現する
- Content-Typeはtext/html
- ステータスコードは基本的に200
- 通信内容がプレーンテキストであり、特別なツールを使わなくても読める

### SOAP(2006年頃)
- XML-RPCの拡張
- SOAP自身はデータ定義フォーマットであり、HTTPの中にミニHTTPのような構造を持っている
- エンタープライズ志向でありスキーマなどを完全装備する方向性で仕様策定されている

### JSON-RPC(2006年)
- XMLの代わりにJSONを使用したRPC
- シンプルな仕様
- POSTメソッド以外に冪等で安全なメソッドを呼び出す際はGETメソッドも使用できる
- 200以外のステータスコードも独自に定めている
- Batchモード
  - リクエストのJSONオブジェクトを複数配列に入れて送信し、一度のHTTPリクエストで複数のプロシージャ呼び出しを行う
    -  レスポンスも配列に入る

## WebDAV
- HTTPを拡張して同期型の分散ファイルシステムとして使用できるようにしたもの
- HTTP/1.1の時代に開発
- MSが開発
- GitでサポートされているSSH、HTTPSのうちHTTPSはWebDAVを使用している

#### 用語
- リソース -> データを格納するファイル
- プロパティ -> リソースやコレクションに追加できる情報(作成者、更新日時etc)
- ロック -> 複数人同時編集によるコンフリクトを防ぐ仕組み

#### 独自に追加されたメソッド
- COPY -> 追加されたメソッド
- MOVE -> 追加されたメソッド
- MKCOL -> 追加されたメソッド / コレクションを作成する
- PROPFIND -> 追加されたメソッド / コレクション内の要素一覧を取得する
- UNLOCK -> 追加されたメソッド / ロックを制御する

## 認証・認可プラットフォーム
- 認証 -> ブラウザを操作しているユーザーが、サービスに登録されているどのアカウントの所有者なのかを確認する
- 認可 -> 認証したユーザーを把握した上でどんな権限を与えるのかを決定する

### シングルサインオン
- 各システム間のアカウント管理を一元化する
- 一つのサービスにサインインすると、関連する全てのシステムが有効になる

#### 方法
- 各サービスが認証サーバーに自前でアクセスする
- 各サービスの前段にHTTPプロキシを置き、認証を代行する
- 各サービスに認証を代行するエージェントを置き、ログイン時に中央のサーバーにログインの有無を問い合わせる
- Kerberos認証
  - LDAP規格
  - チケットとセッションキーをサービスに送る
- SAML(Security Assertion Markup Language)
  - Cookieを使用し、ドメインをまたいだサービス間でシングルサインオンを利用できる
  - 用語
    - ユーザー
    - 認証プロバイダ(idP) -> IDを管理するサービス
    - サービスプロバイダ -> ログインを必要とするサービス
  - 実装方法
    - SAML SOAPバインディング
    - リバースSOAP(PAOS)バインディング
    - HTTPリダイレクトバインディング
    - HTTP POSTバインディング
    - HTTPアーティファクトバインディング
    - SAML URIバインディング
  - メタデータ(XML)を使用して認証プロバイダーとサービスプロバイダーにサービスを登録する
  - ユーザーアクセス時、未ログイン状態であればサービスプロバイダーは認証プロバイダーにリダイレクトを行う
  - ユーザーのブラウザに認証プロバイダの画面を表示
    - ログインに成功した場合、認証プロバイダーはサービスプロバイダーにログイン情報をPOST
    - サービスプロバイダーは最初にリクエストされたコンテンツを返す

### OpenID
- すでに使われているWebサービスのユーザー情報を使い、他のサービスにログインする
  - 後続はOpenID Connect
- 用語
  - OpenIDプロバイダー
    - ユーザー情報を持つWebサービス
  - リライニングパーティー
    - ユーザーが新たに使用したいサービス
  - ユーザー入力識別子
    - OpenIDプロバイダーが提供するユーザー情報(URL形式)
- OpenIDプロバイダのWebサイトからユーザー入力識別子を取得
- リライニングパーティーにユーザー入力識別子を登録
  - リライニングパーティーがOpenIDプロバイダーに対してHTTPで情報交換を行い、秘密鍵を共有
- OpenIDプロバイダーのWebサイトにリダイレクト -> ユーザーが承認 -> リライニングパーティーにリダイレクト

### OpenSocial
- 認証だけでなく会員情報、友人関係、アクティビティ、情報の保存や共有、メッセージ送信など多岐にわたるAPIを有する
- 認可・認証をすべてソーシャルネットワークサービスの事業提供者が行う
- ドメインをまたいだ画オブサーバーへのリクエストやブラウザが使うAjax対応はSNSの外部のガジェットサーバーが行う
- ガジェット提供者(ユーザーが利用したいサービス)とプラットフォーム提供者間の通信はHTTPで行う

### OAuth
- 認証ではなく認可のための仕組み
- 用語
  - 認可サーバー
    - ユーザー情報を持つWebサービス
  - リソースサーバー
    - ユーザーが認可した権限でアクセスできる対象
  - クライアント
    - ユーザーが新たに使用したいサービス
    - 認可サーバーにアプリケーション情報を登録し、専用のID(client_id, client_secret)を取得する必要がある
- OpenIDと同じような画面遷移をする
- フロー
  - Authorization Code
    - 通常のフロー
    - Webサービスのサーバー内にclient_secretを隠せる場合に使用
  - Implicit Code
    - client_secret無しでアクセスできるパターン
    - クライアントの身元を保証しない
    - JSやアプリダウンロード向け
  - Resource Owener Password Credentials Grant
    - 認可サーバーに信頼されているクライアントで使う
    - クライアント自身がユーザーのID/PWに触れる
    - iOS内蔵のFacebook、Twitter向け
  - Clients Credentials Grant
    - ユーザーの同意なしにclient_id、client_secretだけを使用してアクセスできるようにする
    - client_secretを外部から秘匿できる環境で使用

### OpenID Connect
WIP

## セキュリティ

## RESTful API
