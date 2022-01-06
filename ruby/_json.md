# JSON
### `JSON#parse`
```ruby
require 'json'

json = "[{\"foo\":{\"bar\":\"baz\"}}]"

JSON.parse(json)
=> [{"foo"=>{"bar"=>"baz"}}]

JSON.parse(json, symbolize_names: true)
=> [{:foo=>{:bar=>"baz"}}]
```
