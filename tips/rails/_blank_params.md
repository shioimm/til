# バリデーションエラー発生後、パラメータが空になる(STI)
## 挙動
- STIを使用しているモデルに関連するフォームでバリデーションエラーが発生した後、
もう一度フォームを送信しようとするとパラメータが空になる
- その後、再度送信するとパラメータを正常に送信できる

## 状態
- `class Child < Parent`のような形でSTIを使用している
- create時は次のアクションを使用する

```ruby
# parent_controller
def create
  @instance = Parent.new(params)
  @instance.save ? redirect : render
end

def params
  permitted_params = %i[type]
  params.fetch(:parent, {}).permit(permitted_params)
end
```
- パラメータとして次のような値が渡ってくることを期待している
```console
"{ \"parent\"=>{\"type\"=>\"Child\", \"name\"=>\"\"}, \"commit\"=>\"保存\", \"controller\"=>\"parent\", \"action\"=>\"create\"}"
```

## 原因
params = { type: STIの子クラス }の場合、

```ruby
@instance = Parent.new(params)
@instance.save
```

を実行すると、`@instance`は親クラスではなく、子クラスのインスタンスとなる。
saveに失敗した場合はこの`@instance`がview側に渡されるが、
その場合@instanceは子クラスのインスタンスであるため、
フォーム送信時のパラメータが次のようになる。

```console
"{ \"child\"=>{\"type\"=>\"Child\", \"name\"=>\"\"}, \"commit\"=>\"保存\", \"controller\"=>\"parent\", \"action\"=>\"create\"}"
```

このハッシュの中に存在しているkeyは:parentではなく:childであるため、
`params.fetch(:parent, {}).permit(permitted_params)`で値を取得することができず、
ストロングパラメータが空になってしまう。

## 対策
- scopeでprefixを明示する

```ruby
# urlもデフォルトでは子モデルのパスを使用しようとするため、明示的に親モデルのパスを指定する必要がある
= form_with model: @instance, url: parent_path, scope: :parent, local: true do |f|
```

```ruby
# becomesを使っても良かった
= form_with model: @instance.becomes(Parent), url: parent_path, local: true do |f|
```
