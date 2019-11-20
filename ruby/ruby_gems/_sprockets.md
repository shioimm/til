### sprocketsのupdate後、sasscがSegmentation faultを起こす事象
#### 状況
- Rails6.0.0 -> 6.0.1 update時に発生
  - sprockets 3.7.2 -> 4.0.0
- 新たにapp/assets/config/manifest.jsを追加
```js
//= link_tree ../images
//= link_directory ../javascripts .js
//= link_directory ../stylesheets .css
//= link pc/application.css
//= link tablet/application.css
//= link smartphone/application.css
```
- ローカルでテスト実行時は通る
- CIでテスト実行時、Capybara起動の際にSegmentation faultが発生しテストが落ちる
```
.................................*Capybara starting Puma...
* Version 4.3.0 , codename: Mysterious Traveller
* Min threads: 0, max threads: 4
* Listening on tcp://127.0.0.1:43959
/home/circleci/Nozomi/vendor/bundle/ruby/2.6.0/gems/sassc-2.2.1/lib/sassc/engine.rb:42: [BUG] Segmentation fault at 0x0000000000000000
ruby 2.6.2p47 (2019-03-13 revision 67232) [x86_64-linux]

...略

[NOTE]
You may have encountered a bug in the Ruby interpreter or extension libraries.
Bug reports are welcome.
For details: https://www.ruby-lang.org/bugreport.html

Received 'aborted' signal
```

### 解決策
- デフォルトで`true`になっているファイルの同時エクスポート(`export_concurrent`)を`false`にする
```ruby
Rails.application.config.assets.configure do |env|
  env.export_concurrent = false
end
```
- `export_concurrent`の値が`true`の場合`:fast`、`false`の場合`:immediate`として
`Concurrent::Promise.new`(concurrent-ruby)の引数に渡されている
- 参考: [url helpers aren't thread safe](https://github.com/rails/sprockets/issues/581#issuecomment-486984663)
