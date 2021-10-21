# 参照: dRubyによる分散・Webプログラミング
require 'rinda/ring'

DRb.start_service

ts = Rinda::RingFinger.primary
ary = ts.read_all([:name, :Hello, DRbObject, nil])

if ary.size.zero?
  puts "Hello: not found"
  exit 1
end

ary.each do |tuple|
  hello = tuple[2]
  puts hello.greeting
end
