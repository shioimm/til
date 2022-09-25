# 集合演算
- デフォルトで重複が排除される (重複を排除しない場合は`all`オプションを付与)

#### UNION
- 和集合を求める

```sql
select
    *
from
    address1
union
select
    *
from
    address2;
```

#### INTERSECT
- 積集合を求める

```sql
select
    *
from
    address1
intersect
select
    *
from
    address2;
```

#### EXCEPT
- 差集合を求める

```sql
-- address1 - address2となる

select
    *
from
    address1
except
select
    *
from
    address2;
```

## 参照
- SQL実践入門: 高速でわかりやすいクエリの書き方 2.2
