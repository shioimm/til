# 配列型のカラムをwhere句で絞り込む (PostgreSQL)

```
# lanuagesに1つ以上'Ruby'があるUser
User.where("'Ruby' = any (lanuages)")

# lanuagesに["Ruby", "Python"]を含むUser
User.where("lanuages @> array[?]::varchar[]", ["Ruby", "Python"])

# lanuagesを2つ以上持つUser
User.where("array_length(lanuages, 1) >= 2")
```
