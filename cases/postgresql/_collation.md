# 日本語データが保存されたカラムをソートすると意図しない順でデータが返る
- `lc_collate`が`ja_JP.UTF-8`になっていない可能性がある

```sql
show lc_collate; -- => en_US.utf8
```

- `convert_to`関数を使用する

```sql
order by convert_to(<対象のカラム名>,'UTF8') asc -- で意図した並びになる
```

- あるいは環境変数 `LC_ALL=ja_JP.UTF-8` を設定する
