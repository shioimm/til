### config/locales/models/ja.ymlファイルの書き方

#### ActiveModel::Modelをincludeしたクラスの場合
```ruby
class Hoge
  include ActiveModel::Model

  attr_reader :fuga
end
```
```yml
ja:
  activemodel:
    attributes:
      hoge:
        fuga: ふが
```

#### ActiveModel::Modelをincludeしたmodule配下のクラスの場合
```ruby
module Moge
  class Hoge
    include ActiveModel::Model

    attr_reader :fuga
  end
end
```
```yml
ja:
  activemodel:
    attributes:
      moge/hoge:
        fuga: ふが
```

