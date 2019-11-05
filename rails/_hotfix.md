### バリデーションエラー発生後の挙動(STI)
#### 挙動
- STIを使用しているモデルに関連するフォームでバリデーションエラーが発生した後、
もう一度フォームを送信しようとするとストロングパラメータが空になる
- その後、再度送信するとストロングパラメータを正常に送信できる

#### 状態
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

#### 原因
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

#### 対策
- scopeでprefixを明示する
```ruby
# urlもデフォルトでは子モデルのパスを使用しようとするため、明示的に親モデルのパスを指定する必要がある
= form_with model: @instance, url: parent_path, scope: :parent, local: true do |f|
```
```ruby
# becomesを使っても良かった
= form_with model: @instance.becomes(Parent), url: parent_path, local: true do |f|
```

### 二つの似たレコードがページネーションを挟んで存在するとき、片方が表示されない
#### 挙動
- `order(:starts_at, :ends_at)`で並び順を指定したレコードがあり、
その中に同じ`starts_at`と`ends_at`をそれぞれ持つレコードx, yが存在している
- 二つのレコードがページネーションの境界にあるとき、どちらのページでもxが表示され、yが表示されない

#### 原因
- orderしている条件が重複しているとき、どちらのレコードが先に並ぶかがランダムになるため(PostgreSQLの挙動)

#### 対策
- 並び順が必ず一意になるようにorderする
```ruby
order(:starts_at, :ends_at, :id)
```
