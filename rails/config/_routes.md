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

## 参照
- [Railsのルーティング](https://railsguides.jp/routing.html)
