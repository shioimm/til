# explain
- [22 EXPLAINを実行する](https://railsguides.jp/active_record_querying.html#explain%E3%82%92%E5%AE%9F%E8%A1%8C%E3%81%99%E3%82%8B)
- クエリの実行計画を表示する(実際にクエリを発行する)

```ruby
$ User.where(id: 1).joins(:articles).explain

EXPLAIN for: SELECT "users".* FROM "users" INNER JOIN "articles" ON "articles"."user_id" = "users"."id" WHERE "users"."id" = 1
                                  QUERY PLAN
------------------------------------------------------------------------------
Nested Loop Left Join  (cost=0.00..37.24 rows=8 width=0)
   Join Filter: (articles.user_id = users.id)
   ->  Index Scan using users_pkey on users  (cost=0.00..8.27 rows=1 width=4)
         Index Cond: (id = 1)
   ->  Seq Scan on articles  (cost=0.00..28.88 rows=8 width=4)
         Filter: (articles.user_id = 1)
(6 rows)
```

## 参考
- [SQL実行計画の疑問解決には「とりあえずEXPLAIN」しよう](https://thinkit.co.jp/article/9658)
