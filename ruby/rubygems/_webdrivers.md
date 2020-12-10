# webdrivers
- [titusfortner / webdrivers](https://github.com/titusfortner/webdrivers)
- Seleniumでブラウザを起動する際、自動的にドライバーをダウンロード/更新する

### 使い所
- チーム内のChromeDriverのバージョンを揃える場合
```ruby
# spec/rails_helper.rb

# Some specs fail with version 79
Webdrivers::Chromedriver.required_version = '78.0.3904.105'
```
