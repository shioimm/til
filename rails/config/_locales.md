# config/locales/models/ja.yml
```ruby
# ActiveModel::Modelをincludeしたクラスの場合

class Foo
  include ActiveModel::Model
  attr_reader :x
end

module Foo
  class Bar
    include ActiveModel::Model
    attr_reader :y
  end
end
```

```yml
ja:
  activemodel:
    attributes:
      foo:
        x: x
      foo/bar:
        y: y
```
