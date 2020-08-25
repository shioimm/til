# 設定
- 参照: nginx実践ガイド

## `/etc/nginx/nginx.conf`
```
# mainコンテキスト(全体の設定)
user  nginx;         # workerが動作するユーザー名
worker_processes  1; # workerプロセス数の設定 autoに設定するとコア数と同数のプロセスを起動する

error_log  /var/log/nginx/error.log warn; # エラーログの出力先とログレベル
pid        /var/run/nginx.pid;            # プロセスIDを記述したファイルの配置先

# eventsコンテキスト
# イベントループ関連の設定
events {
  worker_connections  1024; # 一つのworkerプロセスが同時に受け付けられる接続数
}

# httpコンテキスト
# Webサーバー全体の設定
http {
  include       /etc/nginx/mime.types; # mime.typesファイルの読み込み
  default_type  application/octet-stream;

  log_format  main  '$remote_addr - $remote_user [$time_local] "$request" ' # ログフォーマットの定義
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

  access_log  /var/log/nginx/access.log  main; # アクセスログの出力先とログフォーマットの指定

  sendfile        on; # ファイルの送信方法を指定(性能向上)
  #tcp_nopush     on;

  keepalive_timeout  65; # Keep-Aliveのサーバー側のタイムアウト時間を指定

  #gzip  on;

  include /etc/nginx/conf.d/*.conf; # 設定ファイルの読み込み
}

# その他事項
#   同じ名前のディレクティブでもコンテキストによって別の意味になることがある
#   条件に合う中で最も内側のコンテキストの設定が優先的に適用される
```

### `/etc/nginx/conf.d/*.conf`
- バーチャルホストの設定
```
server {
  listen 80;                 # listenするポート番号の設定
  server_name *.example.com; # バーチャルホストのサーバーのホスト名
  access_log /var/log/nginx/access.log;
  error_log /var/log/nginx/error.log;

  location / { # パス名に対応するコンテキスト
      root /www/dir;    # ドキュメントルート
      index index.html; # ディレクトリにアクセスした際にレスポンスとして使用されるファイル名
  }
}
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
