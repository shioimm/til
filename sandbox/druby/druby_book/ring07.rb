# 参照: dRubyによる分散・Webプログラミング
require 'rinda/ring'
require_relative './ringnotify'

DRb.start_service

ts = Rinda::RingFinger.primary
ns = RingNotify.new(ts, :Hello)

ns.each do |tuple|
  hello = tuple[2]
  begin
    puts hello.greeting
  rescue
  end
end
