# CASE式

```sql
select
    name
    , address
    , case when address = 'Tokyo'  then 'Japan'
           when address = 'NY'     then 'US'
           when address = 'London' then 'UK'
      else null
      end as country
from
    customers;
```

## 参照
- SQL実践入門: 高速でわかりやすいクエリの書き方 2.2
