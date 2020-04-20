# FactoryBot
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

#### 事例
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
