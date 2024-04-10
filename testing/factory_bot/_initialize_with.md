# `initialize_with`
- FactoryBotでPOROを作成する

```ruby
class PlainUser
  attr_reader :name, :phone_number
end

FactoryBot.define do
  factory :plain_user do
    name { 'plain test user' }
    phone_number { '04012345678' }

    initialize_with { new(**attributes) }
  end
end

user = build(:plain_user)
user.phone_number
```
