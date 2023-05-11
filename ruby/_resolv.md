# library resolv
- Rubyで書かれたthread-awareなDNSリゾルバ
- 複数のDNSリクエストを同時に処理することが可能

```ruby
require 'resolv'

Resolv.getaddress "www.ruby-lang.org"
Resolv.getaddresses "www.ruby-lang.org"

# Resolv::IPv6のリストを返す
Resolv::DNS.new.getresources("www.ruby-lang.org", Resolv::DNS::Resource::IN::AAAA)

# 新しいDNSリゾルバをオープン -> クローズする
Resolv::DNS.open do |dns|
  dns.getresources "www.ruby-lang.org", Resolv::DNS::Resource::IN::AAAA
end
```

## 参照
- [ruby/lib/resolv.rb](https://github.com/ruby/ruby/blob/master/lib/resolv.rb)
- [library resolv](https://docs.ruby-lang.org/ja/3.1/library/resolv.html)
