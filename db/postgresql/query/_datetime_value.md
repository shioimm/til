# 日時から年や時など抽出する

```sql
select
    extract(century from timestamp '2000-12-16 12:21:13');
-- -> 20(世紀)
```

```sql
select
    extract(epoch from timestamp with time zone '2001-02-16 20:38:40.12-08');
-- -> 982384720.12(秒)
```

```sql
-- 日時から時間を抽出する
select
    extract(epoch from sum(hoge.ends_at - hoge.starts_at) / 3600)
-- -> x.x(時間)
```

## 参照
- [PostgreSQL 11.5文書 日付/時刻関数と演算子](https://www.postgresql.jp/document/11/html/functions-datetime.html)
