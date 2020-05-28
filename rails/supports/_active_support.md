### Module::Concerning
- 参照: [Module::Concerning](https://api.rubyonrails.org/v4.1.0/classes/Module/Concerning.html#method-i-concerning)
- models/concernsディレクトリ内にファイルを作成せず、モデルクラス内で関心事の分離を行う
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

### Object#presence_in(another_object)
- 参照: [Ruby on Rails 6.0.0 RDOC_MAIN.rdoc](https://api.rubyonrails.org/)
- レシーバがanother_objectに含まれている場合はレシーバを返し、含まれていない場合は`nil`を返す
- `another_object.respond_to?(:include?)`が`false`の場合、`ArgumentError`が発生する
