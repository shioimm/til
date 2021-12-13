# type属性
- モデルにtype属性 (string) を追加すると、該当するモデルをSTIにすることができる
- typeカラムを追加したテーブルに該当するモデル = スーパークラス
- 該当モデルを継承したクラス = サブクラス
- レコード生成時、type属性にサブクラス名を指定する

```ruby
# Novelモデルのレコードを生成
Book.new(type: 'Novel')

# Bookモデルのレコードを生成
Book.new(type: '')
```

- enumを使用することもできる

```ruby
class Book < ApplicationRecord
  enum type: {
    Novel: 'Novel',
    Magazine: 'Magazine',
  }
```
