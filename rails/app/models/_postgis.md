# PostGIS
### 位置情報型カラム (PostGIS) に値を入力

```ruby
location = RGeo::Geographic.spherical_factory(srid: 4326).point(139.7003912, 35.6897376)
Address.create!(geolocation: location)
```

### はじめかた

```ruby
gem 'activerecord-postgis-adapter'
gem 'rgeo'
```

```sql
CREATE EXTENSION postgis;
```

```ruby
class AddLocationToAddresses < ActiveRecord::Migration[6.0]
  def change
    add_column :name, :location, :st_point, geographic: true
  end
end
```

```ruby
# config/initializers/activerecord-postgis-adapter.rb

RGeo::ActiveRecord::SpatialFactoryStore.instance.tap do |config|
  config.default = RGeo::Cartesian.preferred_factory(srid: 4326)
end
```

## 参照
- https://www.rubydoc.info/github/rgeo/rgeo/RGeo/
