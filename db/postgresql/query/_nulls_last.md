# 値がnullであるレコードを最初に/最後に表示したい
- `nulls last(first)`で制御する

```sql
select row
    from table
    order by row.column desc nulls last
```

## 参照
- [行の並べ替え](https://www.postgresql.jp/document/12/html/queries-order.html)
