# Rails開発におけるテスト
## 用語
- ヘッドレスブラウザ -> GUIがないブラウザ(自動テストのために利用する)

## セットアップ
- rspecのセットアップ
  - [gem 'rspec-rails'](https://github.com/rspec/rspec-rails#installation)
  - `rails generate rspec:install`
- factoryのセットアップ
  - [gem 'factory_bot_rails'](https://github.com/thoughtbot/factory_bot_rails#configuration)
- capybaraのセットアップ
  - Rails5.1以降同梱
```ruby
# spec_helper.rb

require 'capybara/rspec'

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium_chrome_headless
  end
end
```
