# where句に複数のカラムの組み合わせを設定したい

```sql
select *
from   rows
where  (col1, col2) in ((val1a, val2a), (val1b, val2b), ...) ;
```

### Railsの場合

```ruby
queries = [[:val1a, :val2a], [:val1b, :val2b]]
place_holders = Array.new(queries.length, '(?,?)').join(',')
keywords = queries.flatten

rows.where("(col1, col2) IN (#{place_holders})", *keywords)
```

## 参照
- [selecting where two columns are in a set](https://dba.stackexchange.com/questions/34266/selecting-where-two-columns-are-in-a-set)
