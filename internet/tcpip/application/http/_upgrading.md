# プロトコルのアップグレード
- 参照: Real World HTTP 第2版

## 種類
- HTTP -> TLSを使用した安全な通信へのアップグレード(`TLS/1.0` / `TLS/1.1` / `TLS/1.2`)
  - TLSのプロトコル選択機能(ALPN)によってTLSを選択する方法が推奨されている
- HTTP -> HTTP/2へのアップグレード(`h2c`)
  - TLSを前提とし、TLSのプロトコル選択機能(ALPN)によってHTTP/2を選択する方法が推奨されている
- HTTP -> WebSocketを使用した双方向通信へのアップグレード(`websocket`)
  - プロトコルアップデートの主な利用用途

## 利用方法
### クライアント -> サーバー
1. 対象のサーバーがアップグレードに対応しているかOPTIONSメソッドで確認する
```
OPTIONS * HTTP/1.1
```

2. 対象のサーバーに対して`Upgrade`ヘッダ・`Connection`ヘッダを送信する
```
GET / HTTP/1.1
Upgrade: TLS/1.0
Connection: Upgrade
```

3. アップグレードが可能であればサーバーはその旨をレスポンスする
```
HTTP/1.1 426 Upgrade Requied
Upgrade: TLS/1.0 HTTP/1.1
Connection: Upgrade
```

### サーバー -> クライアント
- サーバー側からクライアント側へアップグレードを要請する

```
HTTP/1.1 426 Upgrade Requied
Upgrade: TLS/1.0 HTTP/1.1
Connection: Upgrade
```

- クライアント側は要請を受けてアップグレードのためのハンドシェイクを始める
