# geometry型のカラムで検索する (PostGIS)

```sql
select
    *
from
    addresses
where
    st_y(geolocation) between -90 and 90
and
    st_x(geolocation) between -180 and 180
```

```ruby
Address.where('
  st_y(geolocation) between -90 and 90
  and st_x(geolocation) between -180 and 180
')
```
