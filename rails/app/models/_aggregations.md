# ActiveRecord::Aggregations::ClassMethods
## `compised_of`

```ruby
# 値オブジェクトの定義

class PhoneNumber
  attr_reader :value
  delegate :hash, to: :value

  def initialize(value)
    raise "Phone number is invalid." unless value.match?(/\A0\d{9,10}\z/)
    @value = value.frozen? ? value : value.dup.freeze
  end

  def ==(other)
    self.class == other.class && self.value == other.value
  end
  alias eql? ==

  def mobile?
    value.match?(/\A0[7-9]0\d{8}\z/)
  end
end
```

```ruby
class User < ApplicationRecord
  composed_of :phone_number,
              mapping:     %w[phone_number value],
              class_name:  'PhoneNumber'
              constructor: Proc.new { |n| PhoneNumber.new(n) }
              converter:   Proc.new { |n| n.is_a?(Integer) ? PhoneNumber.new(n) : PhoneNumber.new(n.to_i) }

  # 第一引数    - 値オブジェクトを利用する属性
  # mapping     - モデルの属性と値オブジェクトの属性の対応
  # class_name  - 値オブジェクトのクラス名(default: 値オブジェクトを利用する属性のClassify)
  # allow_nil   - nilを許可するか(default: false)
  # constructor - 値オブジェクトのコンストラクタ(default: :new)
  # converter   - 値オブジェクトのクラスとは異なるクラスのインスタンスが代入された場合の変換方法(default: nil)
end
```

## 参照
- [ActiveRecord::Aggregations::ClassMethods](https://api.rubyonrails.org/classes/ActiveRecord/Aggregations/ClassMethods.html#method-i-composed_of)
- パーフェクトRuby on Rails[増補改訂版] P460-473
