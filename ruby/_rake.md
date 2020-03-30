# Rake
## 事例
### RailsにおけるRakeタスク
- 参考: [rakeタスクを定義するときのおまじない :environment がやっていること](https://qiita.com/vivid_muimui/items/5ef9dfa31f5168190278)
- `:environment`はRailsアプリケーションの`config/environment.rb`
```ruby
namespace :namespace do
  desc 'description'
  task sometask: :environment do |task, args|
    p '======= start ======='

    # 任意の処理

    p '======= finish ======='
  end
end
```

### Rakeタスクに配列の引数を渡すと'no matches found:'
- 原因: 引数の\[\]がエスケープされていない
- 解決: 引数をエスケープ
```
// Before
$ rake namespace:taskname[args]
```
```
// After
$ rake namespace:taskname\[args\]

$ rake 'namespace:taskname[args]'
```
