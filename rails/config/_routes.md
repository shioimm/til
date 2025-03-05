# ルーティング
#### `namespace`
- URL、コントローラが名前空間に入る

```ruby
# GET /admin/articles(admin_articles_path) -> Admin::ArticlesController#index

namespace :admin do
  resources :articles, only: :index
end
```

#### scope module
- コントローラが名前空間に入る

```ruby
# GET /articles(admin_articles_path) -> Admin::ArticlesController#index

scope module: 'admin' do
  resources :articles, only: :index
end
```

#### scope
- URLが名前空間に入る

```ruby
# GET /admin/articles(admin_articles_path) -> ArticlesController#index

scope '/admin' do
  resources :articles, only: :index
end
```

#### `draw`マクロ

```ruby
Rails.application.routes.draw do
  draw(:admin) # config/routes/admin.rbをルーティングファイルとして読み込む
end
```

#### `direct`

```ruby
direct :contact_form do |options|
  uri = URI.parse('https://contact.example.com/')
  if options
    uri.query = URI.encode_www_form(options.compact).presence
  end
  uri.to_s
end
```

- `contact_form_url(user_id: ...)`のような形式で呼び出した際にクエリパラメータに`?user_id=...`を付与する

#### `concern`
- 異なるリソース内にそれぞれ共通のルーティングをconcernで抽出する

```ruby
concern :commentable do
  resources :comments
end
resources :messages, concerns: :commentable

# 以下と同じ
# resources :messages do
#   resources :comments
# end
```

## 参照
- [Railsのルーティング](https://railsguides.jp/routing.html)
