# Headless Chrome

```ruby
Capybara.register_driver :chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  build_selenium_driver(app, options)
end

# RSpec.configureで設定する場合
RSpec.configure do |config|
  config.before(:each, type: :system, js: true) do |ex|
    set_chrome_options = ->(options) do
      options.add_argument('--headless')
    end
  end
end
```
