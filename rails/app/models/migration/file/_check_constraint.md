# `check_constraint`
- テーブルにCHECK制約を設ける

```ruby
# CHECK制約を追加
create_table :TABLE_NAME do |t|
  ...
  t.check_constraint [CONSTRAINT_NAME], [CONSTRAINT]

  # e.g. t.check_constraint "price_check", "price > 100"
end
```

```ruby
# 既存のテーブルにCHECK制約を追加
add_check_constraint :TABLE_NAME, :CONSTRAINT_CONDITION, name: "CONSTRAINT_NAME"

# e.g. add_check_constraint :books, "price > 100", name: "price_check"
```

```ruby
# CHECK制約を削除
remove_check_constraint :TABLE_NAME, name: "CONSTRAINT_NAME"

# e.g. remove_check_constraint :books, name: "price_check"
```

## 参照
- [Rails 6.1: CHECK制約のサポートをマイグレーションに追加（翻訳）](https://techracho.bpsinc.jp/hachi8833/2021_01_15/102970)
