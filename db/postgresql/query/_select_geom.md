# geometory (緯度経度) をhexでエンコードした値をhuman readableに表示する
Well-Known Binary (WKB) 形式のgeometoryデータ

```
0101000020E6100000977B58DA************************
```

```sql
select
    st_x(ST_GeomFromWKB(decode(geolocation, 'hex'))) as longitude,
    st_y(ST_GeomFromWKB(decode(geolocation, 'hex'))) as latitude
from
    addresses;
```