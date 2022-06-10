# `shared_context`
- 実行条件の共通化

```ruby
# spec/support/shared_contexts.rb

# テストの実行中、実行時間を当日中に固定したい
shared_context 'with freeze closing time before' do |closing_time|
  before do
    now = Time.current
    closing_time = closing_time
    current_time = closing_time > now ? now : closing_time
    Timecop.freeze(current_time)
  end

  after do
    Timecop.return
  end
end
```

```ruby
# Usage

include_context 'with freeze termination time before', Time.zone.parse("#{Time.zone.today} 23:59")
```
