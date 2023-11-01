# 位置情報型カラム (PostGIS) に値を入力

```ruby
location = RGeo::Geographic.spherical_factory(srid: 4326).point(139.7003912, 35.6897376)
Address.create!(geolocation: location)
```

## 参照
- https://www.rubydoc.info/github/rgeo/rgeo/RGeo/
