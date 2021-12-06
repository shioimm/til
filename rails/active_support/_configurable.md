# ActiveSupport::Configurable
- [ActiveSupport::Configurable](https://api.rubyonrails.org/classes/ActiveSupport/Configurable.html)

```ruby
class SomeLibrary
  include ActiveSupport::Configurable
  config_accessor :attr1
  config_accessor :attr2, instance_reader: false
  config_accessor :attr3 { :zzz }
end

SomeLibrary.configure do |config|
  config.attr1 = :xxx
  config.attr2 = :yyy
end

SomeLibrary.attr1  # => :xxx
SomeLibrary.attr2  # => NoMethodError: undefined method `attr2'
SomeLibrary.attr3  # => :zzz
SomeLibrary.config # => { :attr1 => :xxx, :attr2 => :yyy, :attr3 => :zzz }
```
