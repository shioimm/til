# BinData
```ruby
require 'bindata'

class Sample < BinData::Record
  endian :big
  uint16 :len
  string :data, :read_length => :len
end

io = File.open(...) # 0003616263
s = Sample.read(io)
p s # => {:len=>8, :data=>"abc"}
```

## 参照
- [dmendel/bindata](https://github.com/dmendel/bindata)
- [BinData - Parsing Binary Data in Ruby](https://github.com/dmendel/bindata/wiki)
