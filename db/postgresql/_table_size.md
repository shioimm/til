# 各テーブルサイズの取得
- 以下の情報を書き出す
  - pgn.nspname (名前空間)
  - relname (テーブル名)
  - size (容量)
  - refrelname
  - relidxrefrelname
  - relfilenode (テーブルのディスク上のファイルノード)
  - relkind (テーブルの種類)
  - reltuples (テーブル内の行数)
  - relpages (テーブル内のブロック数)

```sql
select
  pgn.nspname
  , relname
  , pg_size_pretty(relpages::bigint * 8 * 1024) as size
  , case
    when relkind = 't' then
      (select pgd.relname
       from pg_class pgd
       where pgd.reltoastrelid = pg.oid)
    when nspname = 'pg_toast' and relkind = 'i' then
      (select pgt.relname
       from pg_class pgt
       where substring(pgt.relname from 10) = replace(substring(pg.relname from 10), '_index', ''))
    else
      (select pgc.relname
       from pg_class pgc
       where pg.reltoastrelid = pgc.oid)
    end::varchar as refrelname
  , case
    when nspname = 'pg_toast' and relkind = 'i' then
      (select pgts.relname
       from pg_class pgts
       where pgts.reltoastrelid = (select pgt.oid from pg_class pgt where substring(pgt.relname from 10) = replace(substring(pg.relname from 10), '_index', '')))
    end as relidxrefrelname
  , relfilenode
  , relkind
  , reltuples::bigint
  , relpages
from
  pg_class pg        -- テーブルと、その他に列を保有しているものの一覧
  , pg_namespace pgn -- 名前空間
where
  pg.relnamespace = pgn.oid -- pg.名前空間のOID = pgn.行識別子
  and pgn.nspname not in ('information_schema', 'pg_catalog') -- 名前空間がinformation_schema, pg_catalog以外
order by relpages desc;
```

## 参照
- [PostgreSQLで各テーブルの総サイズと平均サイズを知る](https://qiita.com/awakia/items/99c3d114aa16099e825d#%E3%82%88%E3%82%8A%E8%89%AF%E3%81%84%E3%82%AF%E3%82%A8%E3%83%AA)
- [Monitoring Postgres](https://wiki.postgresql.org/images/a/ab/Pganalyze_Lightning_talk.pdf)
