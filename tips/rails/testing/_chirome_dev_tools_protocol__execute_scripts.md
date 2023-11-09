# `RSpec.configure`で`execute_cdp`を実行する

```ruby
RSpec.configure do |config|
  # ...

  # :execute_cdp_tagを付与したスペックでドキュメントの読み込み完了後に任意のスクリプトを実行
  config.before(:each, :execute_cdp_tag) do |ex|
    @execute_cdp_tag =
      Capybara.current_session.driver.browser.execute_cdp(
        'Page.addScriptToEvaluateOnNewDocument',
        source: <<-JS
      )
      // 実行したいスクリプト
    JS
  end

  # 実行後にスクリプトを削除
  config.after(:each, :execute_cdp_tag) do
    Capybara.current_session.driver.browser.execute_cdp(
      'Page.removeScriptToEvaluateOnNewDocument',
      identifier: @execute_cdp_tag['identifier']
    )
  end
end
```
