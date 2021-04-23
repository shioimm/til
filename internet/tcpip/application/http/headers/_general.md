# 一般ヘッダ
- 参照: よくわかるHTTP/2の教科書P29/38-39/41
- 参照: Real World HTTP 第2版

## Cache-Control
- 参照: [Cache-Control](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Cache-Control)
- クライアントがどのようにリソースをキャッシュするかを指定する

### ディレクティブ
- no-store -> リソースを保存してはいけない
- no-cache -> サーバーへの確認なしにリソースを保存してはいけない
- private -> リソースを受け取った本人だけがキャッシュできる
- public -> 複数のユーザーがリソースを再利用できる(キャッシュサーバーなどへの指示)
- max-age -> 有効期限(秒)だけキャッシュできる

## Connection
- [Connection](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Connection)
- トランザクション完了後もネットワーク接続を開いたままにするかどうかを制御

## Date
- [Date](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Date)
- リソースが生成された日時

## Keep-Alive
- [Keep-Alive](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Keep-Alive)
- TCP/IPの通信を高速化するKeep-Alive機能の設定を操作するためのヘッダ
- Keep-Alive機能は`Connection: Keep-Alive`で有効化される
- HTTP/2では常に有効であるため使用は禁止されている
