# Redis CLI

```
$ redis-cli

127.0.0.1:xxxx> keys *       キー名一覧を取得
127.0.0.1:xxxx> type キー名  キーの型を取得
127.0.0.1:xxxx> get  キー名  キーの値を取得
127.0.0.1:xxxx> ttl  キー名  キーの期限を取得
127.0.0.1:xxxx> del  キー名  特定のキーを削除
127.0.0.1:xxxx> monitor      リアルタイムモニタリング
```

```
127.0.0.1:xxxx> smembers キー名 setの値を取得
```
