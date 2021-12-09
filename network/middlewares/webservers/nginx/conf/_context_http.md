# httpコンテキスト
```
# Webサーバー全体の設定

http {
  # mime.typesファイルの読み込み
  include /etc/nginx/mime.types;

  # レスポンスのデフォルトのMIMEタイプ
  default_type application/octet-stream;

  # ログフォーマットの定義
  log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                  '$status $body_bytes_sent "$http_referer" '
                  '"$http_user_agent" "$http_x_forwarded_for"';

  # アクセスログの出力先とログフォーマットの指定
  access_log /var/log/nginx/access.log main;

  # コンテンツのファイルの読み込みとクライアントへのレスポンスの送信にsendfile APIを使うか
  sendfile on;

  # sendfileが有効なとき、TCP_CORKソケットオプションを使うか
  # レスポンスヘッダとファイルの内容をまとめて送るようになる
  tcp_nopush on;

  # Keep-Aliveのサーバー側のタイムアウト秒数を指定
  keepalive_timeout 65;

  # レスポンスのコンテンツを圧縮するか
  gzip  on;

  # バーチャルサーバーの読み込み
  include /etc/nginx/conf.d/*.conf;
}

# その他事項
#   同じ名前のディレクティブでもコンテキストによって別の意味になることがある
#   条件に合う中で最も内側のコンテキストの設定が優先的に適用される
```

### `/etc/nginx/conf.d/*.conf`
- バーチャルサーバー毎の設定ファイルとして使用する
  - バーチャルサーバーはIPベースあるいは名前ベースで区別する
  - デフォルトでは`default.conf` / `example_ssl.conf`が用意されている

```
server {
  # リクエストを受け付けるIPアドレス・ポート番号 / UNIXドメインソケット
  listen [2001:db8:dead:beef::1]:80;;
  # default_serverパラメータをつけると、このserverディレクティブがデフォルトサーバーになる

  # バーチャルサーバーのホスト名(複数指定可能)
  server_name example.com www.example.com;
  # example.comがプライマリサーバーとなる

  # リダイレクト時、Locationヘッダに埋め込むサーバ名
  #   on  - server_name指定したプライマリサーバー
  #   off - リクエストのHostヘッダフィールドで指定されたホスト名
  server_name_in_redirect on;

  # アクセスログの出力先
  access_log /var/log/nginx/access.log;

  # エラーログの出力先
  error_log /var/log/nginx/error.log;

  # パス名/に対応するコンテキスト
  # パスの条件は前方一致ka正規表現で評価される
  location / {
    # ドキュメントルート
    root /www/dir;
    # 必要に応じて、個別のパスのlocationコンテキストに個別にドキュメントルートを設定する

    # ディレクトリ(/で終わるパス)にアクセスした際にインデックスとして使用されるファイル名
    # httpコンテキスト、serverコンテキスト、locationコンテキストに記述できる
    index index.html index.php /index.php;
    # /index.htmlへ内部リダイレクトさせる
    # index.htmlがなければindex.php、index.phpがなければ/index.phpへフォールバックさせる

    # ファイルの存在チェック
    try_files try_files $uri $uri/ @webapp;
    # リクエストURIのパスに対するファイル(静的コンテンツ)が存在すればそのファイルを返す
    # 存在しなければ動的コンテンツとして@webappに内部リダイレクトさせる
    # @xxx - 名前付きロケーション

    # エラーページ
    # エラーコードが発生したときに表示するページのURIを指定
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
      root /usr/share/nginx/html;
    }
    # 50x系のエラーが発生したとき、/50x.htmlページへ内部リダイレクトさせる

    limit_exept GET POST {
      # GET/POST以外のHTTPメソッドにアクセス制限をかける
      deny all;
    }
  }
}
```

- `locatioin`ディレクティブのパスの指定方法: [nginx連載5回目: nginxの設定、その3](https://heartbeats.jp/hbblog/2012/04/nginx05.html#more)

### `example_ssl.conf`
```
server {
  # SSLのポート番号は443
  listen 443;

  # SSLサーバー証明書で指定したCNと同じサーバー名
  server_name example.jp;

  # SSLを有効化
  ssl on;

  # サーバー証明書
  ssl_certificate /etc/nginx/cert.pem;

  # プライベート鍵
  ssl_certificate_key /etc/nginx/cert.key;

  # 使用するTLS/SSLのバージョン
  ssl_protocols SSLv3 TLSv1;

  # 使用する暗号スイート
  ssl_ciphers HIGH:!aNULL:!MD5;

  # サーバが示した暗号スイートを優先するかどうか
  ssl_prefer_server_ciphers on;

  # SSLセッションキャッシュの種類とサイズの指定
  ssl_session_cache shared:SSL:10m;
  # shared - すべてのワーカープロセスで共有

  # SSLセッションキャッシュのタイムアウトの指定
  ssl_session_timeout 10m;

  location / {
    root /usr/share/nginx/html;
    index index.html index.htm;
  }
}
```

#### HTTPとHTTPSの設定を共有する
```
server {
  # sslパラメータでSSLを有効化する
  # 同一のバーチャルサーバーでHTTP/HTTPSを使用できるようになる
  listen 80;
  listen 443 ssl;

  server_name example.jp;
  ...
```

## 参照
- nginx実践ガイド
- [nginx連載3回目: nginxの設定、その1](https://heartbeats.jp/hbblog/2012/02/nginx03.html#more)
- [nginx連載4回目: nginxの設定、その2](https://heartbeats.jp/hbblog/2012/04/nginx04.html)
- [nginx連載5回目: nginxの設定、その3](https://heartbeats.jp/hbblog/2012/04/nginx05.html#more)
- [nginx連載6回目: nginxの設定、その4](https://heartbeats.jp/hbblog/2012/04/nginx06.html#more)
