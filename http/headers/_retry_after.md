# Retry-After
- ユーザーエージェントがフォローアップリクエストを行う前にどれくらい待つべきかを示すレスポンスヘッダ

#### 503 (Service Unavailable) + Retry-After
- サービス閉塞時 (メンテナンス中など)

#### 429 (Too Many Requests) + Retry-After
- レートリミッティング

#### 301 (Moved Permanently) + Retry-After
- リダイレクトリクエスト発行前

## 参照
- [Retry-After](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Retry-After)
