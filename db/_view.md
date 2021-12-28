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

#### materialized view
- 作成されたVIEWにある程度の永続性を持たせたもの
- 参照する度に再検索する必要がなく、頻繁に参照されるVIEWの場合性能が向上する
- DB内部ではテーブルとして扱われ、元のテーブルが更新されるとVIEWも自動的に反映される

## 参照
- [RDBMSのVIEWを使ってRailsのデータアクセスをいい感じにする【銀座Rails#10】](https://techracho.bpsinc.jp/morimorihoge/2019_06_21/76521)
- [マテリアライズドビュー 【materialized view】 マテビュー / 体現ビュー](https://e-words.jp/w/%E3%83%9E%E3%83%86%E3%83%AA%E3%82%A2%E3%83%A9%E3%82%A4%E3%82%BA%E3%83%89%E3%83%93%E3%83%A5%E3%83%BC.html)
