# references
## `foreign_key`
#### 外部キーと参照先のテーブル名が異なる

```ruby
# postsテーブルからusersテーブルを参照したいが、カラム名はwriter_idにしたい

add_reference :posts, :writer, foreign_key: { to_table: :users }
```

## `index`
#### 新規作成するreference型のカラムにUNIQUE制約を付与したい

```ruby
create_table :profiles do |t|
  t.references :user, foreign_key: true, index: { unique: true }, null: false

  t.timestamps
end
```

- [マイグレーションにおいて参照先テーブル名を自動で推定できないカラムを外部キーとして指定する方法](https://qiita.com/kymmt90/items/03cb9366ff87db69f539)
