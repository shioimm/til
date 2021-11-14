# Module::Concerning
- models/concerns/ディレクトリ内にファイルを作成せず、モデルクラス内で関心事の分離を行う
- `Module::Concerning#concerning` -> 新しいconcernを定義し、Mixinする

```ruby
class Chapter < ApplicationRecord
  belongs_to :book

  concerning :RangeCompactionable do
    delegate :begin, :end, :cover?, to: :range

    private

      def range
        @range ||= starts_at..ends_at
      end
  end
end
```

## 参照
- [Module::Concerning](https://api.rubyonrails.org/v4.1.0/classes/Module/Concerning.html#method-i-concerning)
