# Utility
## よく使うコマンド
```
# 再起動
# 新たなバイナリを使って新しいmaster/workerプロセスを起動し、
# 古いmaster/workerプロセスのうちリクエスト処理中でないものから順次終了させる
$ /sbin/service nginx upgrade
```

### nginxコマンド
```
# 設定ファイルのテスト
$ nginx -t

# 設定ファイルのテスト(詳細)
$ nginx -t

# 実行中のnginxデーモンを停止(fast shutdown)
$ nginx -s stop

# 実行中のnginxデーモンを停止(graceful shutdown)
$ nginx -s quit

# 実行中のnginxデーモンにログファイルを開き直させる
$ nginx -s reopen

# 実行中のnginxデーモンに設定ファイルを再読み込みさせる
$ nginx -s reload
```
