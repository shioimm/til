### namespaceとscope
- from [Rails のルーティング](https://railsguides.jp/routing.html)
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
