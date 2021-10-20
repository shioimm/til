# 参照: dRubyによる分散・Webプログラミング
require 'rinda/ring'

DRb.start_service

ts = Rinda::RingFinger.primary
tuple = ts.read_all([:name, :Hello, DRbObject, nil]).first

if tuple.nil?
  puts "Hello: not found"
  exit 1
end

hello = tuple[2]
puts hello.greeting
