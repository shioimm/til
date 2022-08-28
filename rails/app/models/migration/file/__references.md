# references

#### 外部キーと参照先のテーブル名が異なる場合

```ruby
# postsテーブルからusersテーブルを参照したいが、カラム名はwriter_idにしたい

add_reference :posts, :writer, foreign_key: { to_table: :users }
```

- [マイグレーションにおいて参照先テーブル名を自動で推定できないカラムを外部キーとして指定する方法](https://qiita.com/kymmt90/items/03cb9366ff87db69f539)
