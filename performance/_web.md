# Webサーバー
#### レスポンスの圧縮
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

#### Keep-Alive

```
// nginx

location / {
  proxy_http_version 1.1; // HTTP/1.1
  proxy_set_header Connection ""; // Connectionヘッダの指定
  proxy_pass http://app;
}
```

## 参照
- 達人が教えるWebパフォーマンスチューニング 〜ISUCONから学ぶ高速化の実践
