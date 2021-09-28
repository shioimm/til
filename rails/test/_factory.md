# FactoryBot
### `aliases`
- モデルに別名をつける
  - 引用: [Aliases](https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#aliases)
```ruby
factory :user, aliases: [:author, :commenter] do
  first_name { "John" }
  last_name { "Doe" }
  date_of_birth { 18.years.ago }
end

factory :post do
  author
  title { "How to read a book effectively" }
  body { "There are five steps involved." }
end

factory :comment do
  commenter
  body { "Great article!" }
end
```

### `transient`
- 変数のように一時的な値を柔軟に取り扱うことができる機能
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

- Aモデルに紐づくBのidと、Aモデルに紐づくCのidを格納するモデル(D)のFactory
  - `A has_one B`
  - `C has_many A`
  - バリデーションによってBとCがAに紐づいていることを担保している
  - AはBを生成するtraitを持つFactoryを実装済み
```ruby
FactoryBot.define do
  factory :D do
    transient do
      A { create(:A, :with_B) }
    end

    lesson_note_id { A.B.id }
    student_id { A.C_id }
    teacher_id { nil }
    finished_at { nil }
  end
end
```
