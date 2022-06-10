# `transient`
- 変数のような一時的な値を取り扱う

```ruby
FactoryBot.define do
  factory :user do
    transient do
      random_password { Faker::Internet.password(min_length: 10) }
    end

    email { 'test@example.com' }
    password { random_password }
  end
end
```
