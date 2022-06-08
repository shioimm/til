# MISCONF Redis is configured to save RDB snapshots

- ディスク容量の不足などにより、データをディスクに保存できない

```
[ActiveJob] Failed enqueuing ActionMailer::MailDeliveryJob to Sidekiq(default): Redis::CommandError (MISCONF Redis is configured to save RDB snapshots, but it is currently not able to persist on disk. Commands that may modify the data set are disabled, because this instance is configured to report errors during writes if RDB snapshotting fails (stop-writes-on-bgsave-error option). Please check the Redis logs for details about the RDB error.)
Completed 500 Internal Server Error in 212ms (ActiveRecord: 96.0ms | Allocations: 59317)

Redis::CommandError - MISCONF Redis is configured to save RDB snapshots, but it is currently not able to persist on disk. Commands that may modify the data set are disabled, because this instance is configured to report errors during writes if RDB snapshotting fails (stop-writes-on-bgsave-error option). Please check the Redis logs for details about the RDB error.
```

- Redisを再起動する

```
$ brew services restart redis
```

- (Redisを再起動できない場合) データを別の場所に書き込むようリダイレクトする

```
$ redis-cli
config set dir /path/to/tmp
config set <FileName> temp.rdb
```

- [MISCONF Redis is configured to save RDB snapshots](https://stackoverflow.com/questions/19581059/misconf-redis-is-configured-to-save-rdb-snapshots)
