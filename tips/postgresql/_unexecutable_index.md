# 複合インデックスが効かない
```sql
# index_posts_on_user_id_and_category (user_id,category)

> User.find(905).posts.where(category: 'Diary').reverse_order.limit(1).explain
  User Load (5.4ms)  SELECT "users".* FROM "users" WHERE "users"."id" = $1 LIMIT $2  [["id", 905], ["LIMIT", 1]]
  Task Load (28.7ms)  SELECT "posts".* FROM "posts" WHERE "posts"."user_id" = $1 AND "posts"."category" = $2 ORDER BY "posts"."id" DESC LIMIT $3  [["user_id", 905], ["category", "Diary"], ["LIMIT", 1]]
=> EXPLAIN for: SELECT "posts".* FROM "posts" WHERE "posts"."user_id" = $1 AND "posts"."category" = $2 ORDER BY "posts"."id" DESC LIMIT $3 [["user_id", 905], ["category", "Diary"], ["LIMIT", 1]]
                                           QUERY PLAN
------------------------------------------------------------------------------------------------
 Limit  (cost=0.43..688.82 rows=1 width=618)
   ->  Index Scan Backward using posts_pkey on posts  (cost=0.43..238184.70 rows=346 width=618)
         Filter: ((user_id = 905) AND ((category)::text = 'Diary'::text))
```

```sql
# index_posts_on_category_and_user_id (category,user_id)

> User.find(905).posts.where(category: 'Diary').reverse_order.limit(3).explain
  User Load (2.1ms)  SELECT "users".* FROM "users" WHERE "users"."role" = $1 AND "users"."id" = $2 LIMIT $3  [["role", 4], ["id", 905], ["LIMIT", 1]]
  Task Load (21.0ms)  SELECT "posts".* FROM "posts" WHERE "posts"."user_id" = $1 AND "posts"."category" = $2 ORDER BY "posts"."id" DESC LIMIT $3  [["user_id", 905], ["category", "Diary"], ["LIMIT", 3]]
=> EXPLAIN for: SELECT "posts".* FROM "posts" WHERE "posts"."user_id" = $1 AND "posts"."category" = $2 ORDER BY "posts"."id" DESC LIMIT $3 [["user_id", 905], ["category", "Diary"], ["LIMIT", 3]]
                                                   QUERY PLAN
----------------------------------------------------------------------------------------------------------------
 Limit  (cost=1496.70..1496.71 rows=3 width=622)
   ->  Sort  (cost=1496.70..1497.79 rows=434 width=622)
         Sort Key: id DESC
         ->  Index Scan using index_posts_on_category_and_user_id on posts  (cost=0.43..1491.09 rows=434 width=622)
               Index Cond: (((category)::text = 'Diary'::text) AND (user_id = 905))
(5 rows)
```

- 複合インデックスは先に指定した方の条件から検索される
- インデックスによる検索の対象レコード数が十分でない場合、オプティマイザがインデックスを無視することがある
