# ドライバ

```ruby
Capybara.default_driver # デフォルトで使用しているドライバ (デフォルト: :rack_test)
Capybara.current_driver # 現在テストを実行するために使用しているドライバ
Capybara.javascript_driver # JSを起動するために使用するドライバ (デフォルト: :selenium) js: trueタグで有効化
```

#### ドライバの種類
- `:rack_test`
  - 高速で動作する
  - JavaScript をサポートしていない
  - Rackアプリケーションの外側からHTTPリソースにアクセス出来ない
- `:selenium`
  - Firefoxを動作させるSelenium
- `:selenium_headless`
  - Firefoxを動作させるSelenium (headless)
- `:selenium_chrome`
  - Chromeを動作させるSelenium
- `:selenium_chrome_headless`
  - Chromeを動作させるSelenium (headless)

## 参照
- [ドライバ](https://github.com/willnet/capybara-readme-ja#%E3%83%89%E3%83%A9%E3%82%A4%E3%83%90)
