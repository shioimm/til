# Webアプリケーション
#### レスポンスを圧縮する
- `Accept-Encoding: gzip`が付与されたリクエストに対してレスポンスボディをgzipで圧縮して返す
  - 圧縮レベルの調整
  - アプリケーションサーバー上でレスポンスを圧縮し、圧縮したレスポンスをプロキシを経由して返す

```
// nginx

// gzipを有効化
gzip on;

// gzip圧縮するMIMEタイプ (画像は既に圧縮済みなので除外)
gzip_types text/css text/javascript application/javascript application/x-javascript application/json;

// gzip圧縮の対象となる最小のファイルサイズ
gzip_min_length 1k;
```

#### Keep-Alive (HTTP/1.1) を有効にする

```
// nginx

location / {
  proxy_http_version 1.1; // HTTP/1.1
  proxy_set_header Connection ""; // Connectionヘッダの指定
  proxy_pass http://app;
}
```

#### 静的ファイルの配信
- 静的ファイルはアプリケーションを介さずにリバースプロキシから配信する
  - アプリケーションが静的ファイルの編集機能を持つ場合、URLも同時に変更することで事故を防止する

```
// nginx
server {
  # ...
  location /image/ {
    root /path/to/images/;
    try_files $uri @app;
  }

  location @app {
    proxy_pass http://app:****;
  }
}

// try_files
// パラメータに指定したファイルパスを前から順番にチェック
// ファイルがあればそのファイルの内容をレスポンスとして返す
// ファイルがなければ最後に指定したURIへリダイレクト
```

- Cache-Controlヘッダを用いて静的ファイルをブラウザにキャッシュさせる

## クラウドサービスにおけるパフォーマンスチューニング
- S3, GCS, CDN
  - Content-Typeはどのように付与されるか
  - gzip圧縮できるコンテンツの場合、gzip圧縮されているか
  - Cache-Controlヘッダの設定は変更可能か

## アプリケーション自身がHTTPクライアントになる場合
- 同一ホストへのコネクションを使い回す (TCP / TLSハンドシェイクの発生を抑止)
- リクエストタイムアウトを適切に設定する
- 利用しているHTTPクライアントライブラリが
  同一ホストへのリクエストに対して許可しているコネクション数を確認する
  (同一ホストに大量のリクエストを送る場合)

## 参照
- 達人が教えるWebパフォーマンスチューニング 〜ISUCONから学ぶ高速化の実践