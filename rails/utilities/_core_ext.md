参照: [Ruby on Rails 6.0.0 RDOC_MAIN.rdoc](https://api.rubyonrails.org/)

### Object#presence_in(another_object)
- レシーバがanother_objectに含まれている場合はレシーバを返し、含まれていない場合は`nil`を返す
- `another_object.respond_to?(:include?)`が`false`の場合、`ArgumentError`が発生する
