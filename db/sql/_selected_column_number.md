# 選択列番号

```sql
select   id, name
from     users
order by 2;     -- order by nameと同意
```

```sql
select   ip_address, count(*)
from     access_logs
group by 1      -- group by ip_addressと同意
order by 1;     -- order by ip_addressと同意
```
