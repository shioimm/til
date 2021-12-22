# VIEW
- RDBMSにおいて、SELECT文の実行結果に名前を付けて、TABLEと同じようにアクセスできるようにしたもの

```sql
CREATE TABLE products (
    id             SERIAL       NOT NULL PRIMARY KEY,
    name           VARCHAR(255) NOT NULL,
    price          INTEGER      NOT NULL,
);

INSERT INTO products(name, price)
VALUES ('PRODUCT_A', 100),
       ('PRODUCT_B', 200),
       ('PRODUCT_C', 300);

-- VIEWの作成
CREATE VIEW view_products AS SELECT name FROM products;

SELECT * FROM view_products;

     name  | price
-----------+-------
 PRODUCT_A | 100
 PRODUCT_B | 200
 PRODUCT_C | 300
(3 rows)
```

## 参照
- [RDBMSのVIEWを使ってRailsのデータアクセスをいい感じにする【銀座Rails#10】](https://techracho.bpsinc.jp/morimorihoge/2019_06_21/76521)
