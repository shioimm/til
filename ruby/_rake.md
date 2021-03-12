# Rake
## 事例
### Rakeタスクの中でRakeタスクを呼ぶ
```ruby
Rake::Task["実行したいRakeタスク"].invoke
```

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

### 引数に配列を受け取りたい
- `args.extras`で可変個の引数を受け取ることができる
```ruby
namespace :namespace do
  desc 'description'
  task :task_name, [:user_id] => :environment do |_task, args|
    user_ids = [args.user_id, args.extras].flatten
    # 固定引数id + 可変長引数extrasを配列にまとめる
  end
end
```
```
$ be rake namespace:task_name\[1,2\] // => user_ids = ["1", "2"]
```
