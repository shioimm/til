# `users/:user_id`にアクセスがあったとき、`profiles/:profile_id`に処理を移譲したい
- パスを`controller#action`と直接紐づける

```ruby
get '/users/:id', to: 'profiles#show'
```
