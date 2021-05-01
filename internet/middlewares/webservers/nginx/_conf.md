# 設定
```
# /etc/nginx/nginx.conf

coreモジュールの設定(mainコンテキスト)

events {
  eventモジュールの設定
}

http {
  httpモジュールの設定
  server {
    サーバ毎の設定

    location PATH {
      URI毎の設定
    }
    location PATH {
      URI毎の設定
    }
   ...
  }
  ...
}

mail {
  mailモジュールの設定
}
```

##  mainコンテキスト(全体の設定)
```
# workerプロセスの実行権限ユーザー名
user nginx;

# workerのプロセス数
# autoに設定するとコア数と同数のプロセスを起動する
worker_processes 1;

# エラーログの出力先とログレベル
error_log /var/log/nginx/error.log warn;

# masterプロセスのプロセスIDを保存するファイル
pid /var/run/nginx.pid;
```

## eventsコンテキスト
```
# イベントループ関連の設定

events {
  # 一つのworkerプロセスが同時に受け付けられる接続数
  worker_connections 1024;
}
```

## httpコンテキスト
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

## 内部変数(一部)
- `$request_method`       - リクエストメソッド
- `$args` `$query_string` - クエリ文字列
- `$arg_xxx`              - クエリ文字列`?xxx=`
- `$cookie_xxx`           - Cookie`xxx=`
- `$host` `$http_host`    - ホスト名
- `$uri` `$document_uri`  - リクエストURI
- `$request_uri`          - リクエストURI(クエリ文字列を含む)
- `$http_user_agent`      - ユーザーエージェント
- `$request`              - リクエストライン
- `$server_protocol`      - HTTPプロトコル

### 変数定義
```
# server / locatioin / ifコンテキストで定義可能
set $xxx 値:
```

## 事例
### nginxをリバースプロキシとして使う
- `server` - Webサーバー
- `upstream` - アプリケーションサーバー
```
# proxy_passにupstreamの名前を指名
http {
  upstream app {
    server xxx.xxx.x.xx:80;
    server yyy.yyy.y.yy:80;
    server zzz.zzz.z.zz:80;
  }

  server {
    listen 80:
    location / {
      proxy_pass http://app;
    }
  }
}
```

```
# 転送先が一つの場合、直接IPアドレスとポート番号を指定できる

http {
  server {
    listen 80:
    location / {
      proxy_pass http://xxx.xxx.x.xx:80;
    }
  }
}
```

```
# proxy_passの引数のURLにパス名を含めない場合
#   クライアントから受信したパスがupstreamのアプリケーションサーバーに送信される
# proxy_passの引数のURLにパス名を含める場合
#   クライアントから受信したパスから`location`でマッチした部分を除き、
#   指定したパス名を足したパスがupstreamのアプリケーションサーバーに送信される

http {
  server {
    listen 80:
    location /yyy {
      proxy_pass http://xxx.xxx.x.xx:80/zzz/:
      # GET /yyy      -> GET /zzz/
      # GET /yyy1/aaa -> GET /zzz/1/aaa
    }
  }
}
```

### ヘッダを付与する
```
# 接続先がクライアントである場合

server {
  add_header XXX $xxx;
  add_header YYY $yyy;
}
```

```
# 接続先がupstreamのアプリケーションサーバーである場合
# 追加・変更・削除されるもの以外はクライアントから受信したヘッダがそのまま送信される

server {
  proxy_set_header XXX $xxx;
  proxy_set_header YYY $yyy;
}
```

### nginxをupstreamとして使用する場合、正しいクライアントIPを取得する
```
server {
  set_real_ip_from xx.x.x.x;      # クライアントIPをヘッダの値に書き換える接続元(リバースプロキシ)
  real_ip_header   X-Forwarded-For; # クライアントIPとして扱うHTTPヘッダ
}
```

### Keep-Aliveの時間を設定する
```
# 接続先がクライアントである場合

server {
  keepalive_timeout 60;
}
```

```
# 接続先がupstreamのアプリケーションサーバーである場合

upstream app {
  server    xxx.xxx.x.xx:80;
  keepalive 32; # Keep-Aliveで保持する待機中のコネクション数(workerごと)
}

server {
  location / {
    proxy_http_version 1.1:
    proxy_set_header   Connection "";
    proxy_pass         http://app;
  }
}
```

### upstreamのアプリケーションサーバーで実行されたリダイレクトのLocationを書き換える
```
upstream app1 {
  server xxx.xxx.x.xx:80;
}

server {
  server_name app2.com;
  location /aaa/ {
    proxy_pass     http://app1/bbb/;
    proxy_redirect http://app1/bbb http://app2.com/aaa/; # 変換対象の文字列 変換後の文字列
  }

  location /ccc/ {
    rewrite        ^/ccc/1 /ccc/2;
    proxy_pass     http://app1/ddd/;
    proxy_redirect http://app1/ddd/2 http://app2.com/ccc/1;

    proxy_cookie_path   /ccc/ /aaa/; # 変換対象の文字列 変換後の文字列
    proxy_cookie_domain app1 $server_name;
  }
}
```

### 負荷分散
```
# 重み付け
upstream app {
  server xxx.xxx.x.xx:80 weight=3;
  server yyy.yyy.y.yy:80 weight=2;
  server zzz.zzz.z.zz:80;
}
```

```
#upstreamのアプリケーションサーバーのうち一台をバックアップにする

upstream app {
  server xxx.xxx.x.xx:80;        # 稼働系
  server zzz.zzz.z.zz:80 backup; # 待機系
}
```

```
# upstreamのアプリケーションサーバーのうち接続数が最も少ないものにアクセスする

upstream app {
  least_conn;
  server xxx.xxx.x.xx:80;
  server zzz.zzz.z.zz:80;
}
```

```
# 同じクライアントIPからのアクセスを同じupstreamに接続する

upstream app {
  ip_hash;
  server xxx.xxx.x.xx:80;
  server zzz.zzz.z.zz:80;
}
```

### タイムアウト
```
# ダウン条件の判定

server {
  location /aaa/ {
    proxy_pass            http://app/bbb/;
    proxy_connect_timeout 60s; # 接続時タイムアウト
    proxy_read_timeout    60s; # 受信時タイムアウト
    proxy_send_timeout    60s; # 送信時タイムアウト
  }
}

upstream app {
  server xxx.xxx.x.xx max_fails=1 fail_timeout=10s;
  # max_fails    - 失敗したアクセスの回数
  # fail_timeout - 失敗判定する時間 / 失敗判定後アクセスを控える時間
}
```

### キャッシュ
```
http {
  proxy_cache_path /var/cache/nginx/rproxy # キャッシュディレクトリ
                   levels=1:2              # キャッシュディレクトリ構造(0-9:00-99)
                   keys_zone=zone:10m      # ゾーン(workerの共有メモリ領域)名:サイズ
                   inactive=1d;            # キャッシュが破棄されるまでの時間

  upstream app {
    server xxx.xxx.x.xx:80;
  }

  server {
    location / {
      proxy_cache zone # ゾーン名
      proxy_pass  http://app;

      proxy_cache_bypass $http_authorization $http_cookie; # キャッシュからレスポンスを返さない
      proxy_no_cache     $http_authorization $http_cookie; # コンテンツをキャッシュしない
    }
  }
}
```

### バッファリング
```
server {
  location / {
    proxy_buffering            on;    # バッファリングするかどうか
    proxy_buffer_size          4k;    # レスポンスの先頭部分に使われるメモリ上のバッファサイズ
    proxy_buffers              8 4k;  # proxy_buffer_sizeの次に使われるメモリ上のバッファ数・サイズ
    proxy_max_temp_file_size   1024m; # tempファイルに保存されるバッファサイズ
    proxy_temp_file_write_size 8k;    # tempファイルのバッファに書き出されるデータサイズ
    proxy_busy_buffer_size     8k;    # レスポンス送信中の状態にできるバッファサイズ
  }
}
```

### WebSocketの使用
```
# Upgradeヘッダ・Connectionヘッダをupstreamのアプリケーションサーバーへ転送する

http {
  map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
  }

  server {
    location /aaa/ {
      proxy_pass         http://app;
      proxy_http_version 1.1;
      proxy_set_header   Upgrade    $http_upgrade;
      proxy_set_header   Connection $connection_upgrade;

      proxy_read_timeout 1h; # タイムアウトの設定
    }
  }
}
```

### クライアントIPの同時接続数を制限
```
http {
  limit_conn_zone $binary_remote_addr zone=addr:10m; # 接続数を数えるキー名・ゾーン名・ゾーンサイズ

  server {
    limit_conn addr 10; # ゾーン名・最大接続数
  }
}
```

### クライアントIPのリクエスト数のスループットを制限
```
http {
  limit_conn_zone $binary_remote_addr zone=addr:10m; # 接続数を数えるキー名・ゾーン名・ゾーンサイズ

  server {
    limit_req zone=addr burst=10; # ゾーン名・10アクセスまでは毎秒1リクエストとしてスループットさせる
  }
}
```

### リクエスト毎の帯域を制限
```
http {
  server {
    limit_rate        50k;  # 秒毎に許可するバイト数
    liimit_rate_after 500k; # 帯域制限をかけないバイト数
  }
}
```

## 参照
- nginx実践ガイド
- [nginx連載3回目: nginxの設定、その1](https://heartbeats.jp/hbblog/2012/02/nginx03.html#more)
- [nginx連載4回目: nginxの設定、その2](https://heartbeats.jp/hbblog/2012/04/nginx04.html)
- [nginx連載5回目: nginxの設定、その3](https://heartbeats.jp/hbblog/2012/04/nginx05.html#more)
- [nginx連載6回目: nginxの設定、その4](https://heartbeats.jp/hbblog/2012/04/nginx06.html#more)
