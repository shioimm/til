# rails_admin

### ダッシュボードを非表示にしたい
- 参照: [Controlling visibility](https://github.com/sferik/rails_admin/wiki/Actions#controlling-visibility)
- 全テーブルにクエリを投げるためDBに負荷がかかる
- 無効にしたいアクションに`false`を渡す
```ruby
# config/initializers/rails_admin.rb

RailsAdmin.config do |config|
  config.actions do
    dashboard  do
      statistics false
    end
    index
    new
    show
    edit
    delete
  end
end
```

### フォームをカスタムしたい
- 参照: [Form rendering](https://github.com/sferik/rails_admin/wiki/Fields#form-rendering)
- カスタムしたいフィールドにパーシャルを渡す
```ruby
# config/initializers/rails_admin.rb

RailsAdmin.config do |config|
  config.model 'Person' do
    edit do
      field :name
      field :address do
        partial "address_partial"
      end
      field :phone_number
    end
  end
end
```
- パーシャルは`app/views/rails_admin/main/`ディレクトリ配下に置く
