# Webサーバー
- `Accept-Encoding: gzip`が付与されたリクエストに対してレスポンスボディをgzipで圧縮して返す

```
// nginx

// gzipを有効化
gzip on;

// gzip圧縮するMIMEタイプ (画像は既に圧縮済みなので除外)
gzip_types text/css text/javascript application/javascript application/x-javascript application/json;

// gzip圧縮の対象となる最小のファイルサイズ
gzip_min_length 1k;
```

## 参照
- 達人が教えるWebパフォーマンスチューニング 〜ISUCONから学ぶ高速化の実践
