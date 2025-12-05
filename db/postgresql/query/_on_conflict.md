# selectの結果をinsertしつつunique違反が発生した場合は更新

```sql
insert into users (email)
select email
from legacy_users -- legacy_usersからusersへ
on conflict (email)
do update set
  email = excluded.email
```
