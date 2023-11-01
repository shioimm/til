# `ActiveRecord::RecordNotDestroyed`の原因を知りたい
- `destroy`をオーバーライドする
```ruby
class XxxModel < ApplicationRecord
  def destroy
    begin
      super
    rescue ActiveRecord::RecordNotDestroyed => e
      puts e.record.errors
    end
  end
end
```
