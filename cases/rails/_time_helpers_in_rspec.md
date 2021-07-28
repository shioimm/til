# RSpecでActiveSupport::Testing::TimeHelpersを使用する
- [ActiveSupport::Testing::TimeHelpers](https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html)

```ruby
# rails_helper.rb

RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers
end
```

```ruby
before do
  travel_to(Time.current.yesterday)
end

after do
  travel_back
end
```
