# ウィンドウ関数
- 集約せずに集約関数を使用する
  - グループ化 - `集約関数 over(partition by グループ化すカラム)`
  - ソート - `集約関数 over(order by ソートキー)`
  - グループ化 + ソート - `集約関数 over(partition by グループ化するカラム order by ソートキー)`

```sql
select
    address
    , count(*) over(partition by address)
from
    customers;

select
    name
    , count(*) over(order by name asc)
from
    customers;
```

```sql
select
    category
    , name
    , price
    , row_number() over(partition by category order by price asc) as rank
from
    products
where
    rank = 1
;

-- categoryごとにpriceが高いproductを取得
```

#### 使用できる集約関数
- 通常の集約関数
- `rank` / `dense_rank`
- `row_number` ...

## 参照
- SQL実践入門: 高速でわかりやすいクエリの書き方 2.2
