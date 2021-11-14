# Object
#### `presence_in(another_object)`
- レシーバが`another_object`に含まれている場合はレシーバを返し、含まれていない場合は`nil`を返す
- `another_object.respond_to?(:include?)`が`false`の場合、`ArgumentError`が発生する
