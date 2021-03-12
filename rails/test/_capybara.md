# Capybara
### Feature Specの失敗時にスクリーンショットを残す

```ruby
RSpec.configure do |config|
  config.after do |e|
    if example.metadata[:type] == :feature and e.exception
        page.save_screenshot "screenshot/#{Time.current.strftime('%H%M%S%6N')}.png"
    end
  end
end
```
