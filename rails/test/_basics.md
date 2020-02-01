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

## システムテストについて(System Spec / Feature Spec)
- FeatureからSystemへ移行が必要
- SystemはFeatureに比較して以下の機能をサポートしている
  - テスト終了時に自動的にDBをロールバック(database_cleanerが不要)
  - テスト失敗時のスクリーンショットをデスクトップに保存(capybara-screenshotが不要)
  - スペックごとのブラウザ切り替えが可能(driven_by)

## スタブ / モックの違い
- 参照: [Rails tips: RSpecのスタブとモックの違い（翻訳）](https://techracho.bpsinc.jp/hachi8833/2018_04_25/55467)
- スタブ -> 指定のメソッドを呼んだ際、本来のメソッドを実行せず、欲しい値を返させる(`allow`)
- モック -> 指定のメソッドがテスト中に実行されたかどうかをチェックする(`expect`)
- スタブを利用してモックをチェックするテストの構造をスパイと呼ぶ
