# `check_constraint`
- テーブルにCHECK制約を設ける

## 新規テーブル

```ruby
create_table :TABLE_NAME do |t|
  ...
  t.check_constraint <制約名>, <制約条件>
  # e.g. t.check_constraint "price_check", "price > 100"
end
```

## 既存テーブル

```ruby
# CHECK制約を追加
add_check_constraint :<テーブル名>, "<制約条件>", name: "<制約名>"
# e.g. add_check_constraint :books, "price > 100", name: "price_check"

# CHECK制約を削除
remove_check_constraint :<テーブル名>, name: "<制約名>"
# e.g. remove_check_constraint :books, name: "price_check"
```

## 参照
- [Rails 6.1: CHECK制約のサポートをマイグレーションに追加（翻訳）](https://techracho.bpsinc.jp/hachi8833/2021_01_15/102970)
