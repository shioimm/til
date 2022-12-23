# `spec/`以下で定義されているfactoryを`spec/`の外で利用したい
- 次のディレクトリ以下にfactoryが定義されている場合、
  `FactoryBot.find_definitions`を呼ぶことによって定義済みのfactoryを利用できる

```test/factories.rb
test/factories.rb
spec/factories.rb
test/factories/*.rb
spec/factories/*.rb
```

```ruby
# lib/tasks/create_test_users.rake

require 'factory_bot'

desc 'Just for test'
task create_test_users: :environment do |_task, _args|
  FactoryBot.find_definitions

  FactoryBot.create_list(:users, 10)
end
```

## 引用
- [Definition file paths](https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#definition-file-paths)
