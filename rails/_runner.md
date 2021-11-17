# Rails runner
```ruby
# lib/scripts/insert_initial_user.rb

module Scripts
  class User
    def self.insert_initial_records
      users = %w[TestUser1 TestUser2].map { |name| User.new(name: name) }
      User.import(users)
    end
  end
end
```

```
$ rails runner rails runner Scripts::User.insert_initial_records
```

## 参照
- [rails runner](https://railsguides.jp/command_line.html#rails-runner)
