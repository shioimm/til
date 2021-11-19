# Graceful restart
#### regular restarts
- コネクションが失われ、新しいアプリケーションプロセスの起動後に新しいコネクションが確立される

#### hot restarts
- コネクションは新しいアプリケーションサーバーワーカーの起動するまで維持される

```
$ kill -SIGUSR2 pid

# or

$ pumactl restart
```

#### phased restarts
- 現在のコネクションは古いワーカーで終了し、新しいワーカーが新しいコネクションを処理する

```
$ kill -SIGUSR1 pid

# or

$ pumactl phased-restart
```

## 参照
- [Puma graceful restarts](https://nts.strzibny.name/puma-graceful-restarts/)
