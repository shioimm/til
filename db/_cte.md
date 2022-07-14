# 共通テーブル式 (CTE: Common Table Expression)
- WITH句を用いて定義される一時的なテーブル (としてのサブクエリ)

```sql
WITH 名前 AS (サブクエリ)
```

```sql

WITH regional_sales AS (
  SELECT region, SUM(amount) AS total_sales
  FROM orders
  GROUP BY region
),
top_regions AS (
  SELECT region
  FROM regional_sales
  WHERE total_sales > (SELECT SUM(total_sales)/10 FROM regional_sales)
)
SELECT region,
       product,
       SUM(quantity) AS product_units,
       SUM(amount) AS product_sales
FROM orders
WHERE region IN (SELECT region FROM top_regions)
GROUP BY region, product;
```

```ruby
Post.with(
  posts_with_comments: Post.where("comments_count > ?", 0),
  posts_with_tags: Post.where("tags_count > ?", 0)
)

# WITH posts_with_comments AS (
#   SELECT * FROM posts WHERE (comments_count > 0)
# ), posts_with_tags AS (
#   SELECT * FROM posts WHERE (tags_count > 0)
# )
#
# SELECT * FROM posts
```

## 参照
- [7.8. WITH問い合わせ（共通テーブル式）](https://www.postgresql.jp/document/13/html/queries-with.html)
- [Common Table Expression support added “out-of-the-box” by vlado · Pull Request #37944 · rails/rails](https://github.com/rails/rails/pull/37944)
