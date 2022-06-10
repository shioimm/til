# Timecopの代わりにActiveSupport::Testing::TimeHelpersを使用する

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

```ruby
before do
  freeze_time
end

after do
  unfreeze_time
end
```

## 参照
- [ActiveSupport::Testing::TimeHelpers](https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html)
