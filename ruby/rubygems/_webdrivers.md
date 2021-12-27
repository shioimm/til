# webdrivers
- Seleniumでブラウザを起動する際、自動的にWebDriverをインストール・アップデートする

```ruby
# チーム内のChromeDriverのバージョンを揃える
# spec/rails_helper.rb

# Some specs fail with version 79
Webdrivers::Chromedriver.required_version = '78.0.3904.105'
```

## 参照
- [titusfortner / webdrivers](https://github.com/titusfortner/webdrivers)
