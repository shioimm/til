# ルーティング
- 参照: [Railsのルーティング](https://railsguides.jp/routing.html)

### namespaceとscope
- namespace
  - URL、コントローラが名前空間に入る
```ruby
namespace :admin do
  resources :articles, only: :index
end
```
|HTTPメソッド|URL|コントローラ#アクション|ヘルパー|
|---|---|---|---|
|GET|/admin/articles|admin/articles#index|admin_articles_path|

- scope module
  - コントローラのみが名前空間に入る

```ruby
scope module: 'admin' do
  resources :articles, only: :index
end
```
|HTTPメソッド|URL|コントローラ#アクション|ヘルパー|
|---|---|---|---|
|GET|/articles|admin/articles#index|admin_articles_path|

- scope
  - URLのみが名前空間に入る

```ruby
scope '/admin' do
  resources :articles, only: :index
end
```
|HTTPメソッド|URL|コントローラ#アクション|ヘルパー|
|---|---|---|---|
|GET|admin/articles|articles#index|admin_articles_path|

### `users/:user_id`にアクセスがあったとき、`profiles/:profile_id`に処理を移譲したい
- パスを`controller#action`と直接紐づける

```ruby
get '/users/:id', to: 'profiles#show'
```

## トラブルシューティング
### 意図していないshowアクションが呼ばれる
```ruby
# users/searchにアクセスした際、Users::SearchController#indexではなくUsersController#showが呼ばれる

Rails.application.routes.draw do
  get '/users/:id', to: 'profiles#show'

  resource :users, only: %i[] do
    resources :searches, only: :index, controller: 'users/searches'
  end
end
```
- 'searches'をidとして読み込んでしまうことが原因
  - ルーティングは上から読み込まれるため、順番を入れ替える

```ruby
Rails.application.routes.draw do
  resource :users, only: %i[] do
    resources :searches, only: :index, controller: 'users/searches'
  end

  get '/users/:id', to: 'profiles#show'
end
```
