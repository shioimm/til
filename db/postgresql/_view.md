# VIEW
- 一つ以上のテーブルに対する任意の問い合わせの結果に名前をつけてテーブルのように表現したもの
  - データの実体を持たず、VIEW定義としてクエリを保持し、
    VIEWへの問い合わせに対しては定義されたクエリを実行して結果を返す
  - 元のテーブルが更新されるとVIEWの内容にも自動的に反映される
  - VIEWには実体がないため、VIEWに対するテーブルサイズの取得関数の実行結果は0になる

```sql
create table products (
  id    serial       not null primary key,
  name  varchar(255) not null,
  price integer      not null,
);

insert into products(name, price)
values ('PRODUCT_A', 100), ('PRODUCT_B', 200), ('PRODUCT_C', 300);

-- VIEWの作成
create view viewed_products as select name from products;

select * from view_products;

     name  | price
-----------+-------
 PRODUCT_A | 100
 PRODUCT_B | 200
 PRODUCT_C | 300
(3 rows)
```

## materialized VIEW
- VIEWの作成時に指定した結果を実行し、その結果を永続的に保持するテーブル (実体化されたVIEW)
- 参照する度に再検索する必要がなく、頻繁に参照されるVIEWの場合性能が向上する
- 元のテーブルが更新されてもmaterialized VIEWには自動的に反映されない
  - 元のテーブルの更新後にmaterialized VIEWの内容を更新する場合は
    `refresh materialized view`コマンドの実行が必要
  - materialized VIEWの内容を更新する場合、以前の結果を破棄して新規にmaterialized VIEWを再作成するため、
    新規作成時と同等のコストが発生する

## 参照
- [RDBMSのVIEWを使ってRailsのデータアクセスをいい感じにする【銀座Rails#10】](https://techracho.bpsinc.jp/morimorihoge/2019_06_21/76521)
- [マテリアライズドビュー 【materialized view】 マテビュー / 体現ビュー](https://e-words.jp/w/%E3%83%9E%E3%83%86%E3%83%AA%E3%82%A2%E3%83%A9%E3%82%A4%E3%82%BA%E3%83%89%E3%83%93%E3%83%A5%E3%83%BC.html)
- SQL実践入門: 高速でわかりやすいクエリの書き方 5.4
