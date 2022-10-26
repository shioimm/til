# Capybara
#### Chromeオプション

```ruby
RSpec.configure do |config|
  config.before(:each, type: :system, js: true) do |ex|
    set_chrome_options = ->(options) do
      options.add_argument('--headless') # HeadlessChromeでテストを実行する場合
    end
  end
end
```
