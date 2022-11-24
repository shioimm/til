# cron

```
cron(* * * * *)
```

| 位置  | 実行頻度 | 指定可能数字                   |
| -     | -        | -                              |
| 左端  | 分単位   | 0 ~ 59                         |
| 2番目 | 時単位   | 0 ~ 23                         |
| 3番目 | 日単位   | 1 ~ 31                         |
| 4番目 | 月単位   | 1 ~ 12                         |
| 右端  | 曜日     | 0 ~ 7 (日曜始まり・日曜終わり) |

- 方言があるので実行されるコンテキストを考慮する
  - [CRONTAB](https://nxmnpg.lemoda.net/ja/5/crontab)
  - [CloudWatch](https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/events/ScheduledEvents.html#CronExpressions)
