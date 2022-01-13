# Object
#### `presence_in(another_object)`
- レシーバが`another_object`に含まれている場合はレシーバを返し、含まれていない場合は`nil`を返す
- `another_object.respond_to?(:include?)`が`false`の場合、`ArgumentError`が発生する

```ruby
params[:language].presence_in %w( Ruby PHP Python )
```

#### `try(*args, &block)`
- レシーバに対して`args`メソッドを呼び出す
- レシーバが応答できる場合は実行結果を返し、応答できない場合は`nil`を返す

```ruby
@user.try(:address)
# => @user.address if @user.respond_to?(address)と同じ

@user.try(:address).try(:pref)
#=> @user.address.pref if @user && @user.address.preefと同じ
```

- レシーバに対してブロック内のコードの実行を試みる

```ruby
@users.try do |users|
  if zipcode
    users.searched_by_zipcode(zipcode)
  else
    users
  end
end
```
