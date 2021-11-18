# 優先度制御 (Extensible Prioritization Scheme for HTTP)
- クライアントはpriorityヘッダを用いて8段階(0~7)でリクエストの優先度を表現する
- サーバーが複数のリクエストを受け付けた際、priorityヘッダの値を見て優先度の高いものからレスポンスを返す
- クライアントはレスポンスを受け取っている最中に優先度を変更することが可能
  - HTTP/3ではクライアントがControlストリームで`PRIORITY_ UPDATE`フレームを送信し、優先度を変更する

```
priority: u=5, i
```

- u - Urgency: 値が小さいほど優先度が高い
- i - Incremental: 受信しながら逐次処理可能であることを示す(画像など)

## 参照
- WEB+DB PRESS Vol.123 HTTP/3入門
