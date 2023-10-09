# 参照: drubyによる分散・webプログラミング
require 'drb/drb'
require 'drb/acl'

acl = ACL.new(%w[deny all
                 allow 192.168.0.0/24
                 allow localhost])
# DRb.install_acl(acl)
DRb.start_service('druby://localhost:12345', {}, { tcp_acl: acl })
DRb.thread.join

# irb -r drb
# irb(main):001:0> DRb.start_service
# irb(main):002:0> ro = DRbObject.new_with_uri('druby://localhost:12345')
# => #<DRb::DRbObject:0x00007fbbdb0de140 @ref=nil, @uri="druby://localhost:12345">
# irb(main):003:0> ro.keys
# /Users/misakishioi/.rbenv/versions/3.0.1/lib/ruby/3.0.0/drb/drb.rb:580:in `read': Connection reset by peer (DRb::DRbConnError)
# from /Users/misakishioi/.rbenv/versions/3.0.1/lib/ruby/3.0.0/drb/drb.rb:580:in `load'
# from /Users/misakishioi/.rbenv/versions/3.0.1/lib/ruby/3.0.0/drb/drb.rb:639:in `recv_reply'
# from /Users/misakishioi/.rbenv/versions/3.0.1/lib/ruby/3.0.0/drb/drb.rb:941:in `recv_reply'
# from /Users/misakishioi/.rbenv/versions/3.0.1/lib/ruby/3.0.0/drb/drb.rb:1324:in `send_message'
# from /Users/misakishioi/.rbenv/versions/3.0.1/lib/ruby/3.0.0/drb/drb.rb:1143:in `block (2 levels) in method_missing'
# from /Users/misakishioi/.rbenv/versions/3.0.1/lib/ruby/3.0.0/drb/drb.rb:1302:in `open'
# from /Users/misakishioi/.rbenv/versions/3.0.1/lib/ruby/3.0.0/drb/drb.rb:1142:in `block in method_missing'
# from /Users/misakishioi/.rbenv/versions/3.0.1/lib/ruby/3.0.0/drb/drb.rb:1161:in `with_friend'
# from /Users/misakishioi/.rbenv/versions/3.0.1/lib/ruby/3.0.0/drb/drb.rb:1141:in `method_missing'
# from (irb):4:in `<main>'
# from /Users/misakishioi/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/irb-1.3.5/exe/irb:11:in `<top (required)>'
# from /Users/misakishioi/.rbenv/versions/3.0.1/bin/irb:23:in `load'
# from /Users/misakishioi/.rbenv/versions/3.0.1/bin/irb:23:in `<main>'
