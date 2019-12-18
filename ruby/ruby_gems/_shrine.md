# shrine
## Plugin
### instrumentation
- 参照: [Instrumentation plugin - a better "logging" plugin](https://github.com/shrinerb/shrine/issues/387)
- Shrine3系以上で削除される`logging`プラグインの上位互換として導入された
- 従来の`logging`の機能に加え、外部のロギング機能を使用できる
  - デフォルトでは`ActiveSupport::Notifications`にイベントをサブスクライブする
  - テスト環境でもサブスクライブが実行されてしまうため、使用にあたっては次のような制限を入れた
```ruby
if !Rails.env.test? || ENV['SHRINE_INSTRUMENTATION']
  Shrine.plugin :instrumentation
end
```
