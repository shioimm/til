# GeoJSON
- オープン規格の地理空間データ交換形式

```sql
-- PostGISではst_asgeojson関数で取得できる

select
    ST_AsGeoJSON(geo)
from
    map;
```
