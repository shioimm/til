# forwardable
- [library forwardable](https://docs.ruby-lang.org/ja/3.0.0/library/forwardable.html)

```ruby
require 'forwardable'

class Source
  extend Forwardable
  def_delegators :dst, :deligated

  def initialize(dst)
    @dst = dst # Destinationオブジェクト
  end

  def deligated; end
end

class Destination
  def deligated; end
end

dest = Destination.new
Source.new(dst).deligated
```
