# 拡張機能
#### 拡張機能をインストール

```sql
-- postgisをインストール
create extension postgis;
```

#### `pg_extension`カタログ
- インストールした拡張に関する情報を格納する
- https://www.postgresql.jp/document/15/html/catalog-pg-extension.html

```sql
-- インストールしている拡張機能一覧を取得
select * from pg_extension;
```
