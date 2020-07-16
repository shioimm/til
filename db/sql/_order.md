# order
- 参照: [行の並べ替え](https://www.postgresql.jp/document/12/html/queries-order.html)

### 値がnullであるレコードを最初に/最後に表示したい
```sql
select row
    from table
    order by row.column desc nulls last
```
- `nulls last(first)`で制御する
