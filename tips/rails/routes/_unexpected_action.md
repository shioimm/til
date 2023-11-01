# 意図していないshowアクションが呼ばれる

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
