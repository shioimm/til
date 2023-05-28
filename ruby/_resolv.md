# library resolv
- Rubyで書かれたthread-awareなDNSスタブリゾルバ
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

## 構成クラス
- `Resolv::Hosts` - システムの`hosts`ファイルを使用するローカルのHostnameリゾルバ
- `Resolv::DNS`   - DNSスタブリゾルバ
- `Resolv::IPv4`  - IPv4アドレスを表す
- `Resolv::IPv6`  - IPv6アドレスを表す
- `Resolv::MDNS`  - マルチキャストDNS (mDNS) リゾルバ

## 参照
- [ruby/lib/resolv.rb](https://github.com/ruby/ruby/blob/master/lib/resolv.rb)
- [library resolv](https://docs.ruby-lang.org/ja/3.1/library/resolv.html)
