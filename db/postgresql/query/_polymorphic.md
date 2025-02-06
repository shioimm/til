# ポリモーフィック関連の先のテーブルの情報を取得したい
- `left joins`で結合した後、`coalesce`で有効な方のidを取得する

```
select
    cakes.id
    , fruits.id
from
    me
left join
    strawberries on strawberries.id = cakes.topping_fruit_id
left join
    cherries on cherries.id = cakes.topping_fruit_id
left join
    fruits on fruits.id = coalesce(strawberries.fruit_id, cherries.fruit_id)
```
