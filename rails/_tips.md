### `Your Disk is Almost Full on macOS`
- logディレクトリの容量が増えて警告が表示されている場合は`rails log:clear`でlogを抹消できる
  - ただしsidekiq.logを除く

```console
❯❯❯ ls -lh log
 28M Oct  9 09:20 development.log
3.3M Oct  4 10:43 sidekiq.log
1.2G Oct  8 16:58 test.log

❯❯❯ rails log:clear

❯❯❯ ls -lh log
  0B Oct  9 12:41 development.log
3.3M Oct  4 10:43 sidekiq.log
  0B Oct  9 12:41 test.log
```
