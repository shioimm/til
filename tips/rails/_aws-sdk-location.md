# aws-sdk-location

```ruby
gem 'aws-sdk-location'
gem 'activerecord-postgis-adapter'
gem 'rgeo'
```

```ruby
require 'aws-sdk-location'
require 'rgeo'

client = Aws::LocationService::Client.new(
  region: "<Region>",
  credentials: Aws::Credentials.new("<access_key_id>", "<secret_access_key>")
)

# PlaceIndex = ジオコーディング機能を提供するリソース。AWSコンソールから作成しておく。
response = client.search_address_index_for_text({
  index_name: "<PlaceIndexName>",
  text: "<住所を表す文字列>",
  max_results: 1,
})

if response.results.any?
  point = response.results.first.address.geometry.point
  longitude, latitude = point
  factory = RGeo::Geographic.spherical_factory(srid: 4326)

  address = Address.new(name: "<住所を表す文字列>", location: factory.point(longitude, latitude))
  address.save
end
```
