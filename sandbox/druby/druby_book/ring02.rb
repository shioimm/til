# 参照: dRubyによる分散・Webプログラミング
require 'rinda/ring'

DRb.start_service

ts = Rinda::RingFinger.primary
tuple = ts.read([:name, :Hello, DRbObject, nil])
hello = tuple[2]
puts hello.greeting
