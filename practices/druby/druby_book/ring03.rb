# 参照: dRubyによる分散・Webプログラミング
require 'rinda/ring'

DRb.start_service

ts = Rinda::RingFinger.primary

begin
  tuple = ts.read([:name, :Hello, DRbObject, nil], 0)
rescue Rinda::RequestExpiredError
  puts "Hello: not found"
  exit 1
end

hello = tuple[2]
puts hello.greeting
