### `Your Disk is Almost Full on macOS`の警告が出る
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

### paramsを表示したい
- `output error: #<ActionController::UnfilteredParameters: unable to convert unpermitted parameters to hash>`
- コントローラでparamsを呼ぼうとすると発生する
- 回避策としては`puts params`もしくは`params.to_s`

### manifest.jsonを確認したい
- ブラウザから`/packs/manifest.json`にアクセスする

### View以外の場所からViewHelperを呼びたい
- `ApplicationController.helpers`を使用する
```ruby
ApplicationController.helpers.time_ago_in_words(updated_at)
```
- [controllerのみ]`view_context`を使用する
```ruby
view_context.time_ago_in_words(updated_at)
```
