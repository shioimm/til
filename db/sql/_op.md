# 演算子
#### 文字列連結演算子 -> `||`

```sql
select
  firstname || ' ' || lastname as fullname
from
  users
;
```

#### 比較演算子

| 演算子        | 用法                    |
| -             | -                       |
| `=`           | `x = y`                 |
| `<>`          | `x <> y`                |
| `<`           | `x < y`                 |
| `<=`          | `x <= y`                |
| `>`           | `x > y`                 |
| `>=`          | `x >= y`                |
| `in`          | `x in y`                |
| `not in`      | `x not in y`            |
| `between`     | `x between y and z`     |
| `not between` | `x not between y and z` |
| `exists`      | `x exists y`            |
| `not exists`  | `x not exists y`        |
| `like`        | `x like y`              |
| `not like`    | `x not like y`          |
| `is null`     | `x is null`             |
| `is not null` | `x is not null`         |
