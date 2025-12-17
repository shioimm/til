# default_gemに適用した変更を同期する

```ruby
$ ruby tool/sync_default_gems.rb {gem名} {コミットハッシュ}
```

対象のコミットをcherry-pickした状態になるので、このコミットが必要なブランチにpushする
