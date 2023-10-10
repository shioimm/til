# 参照: dRubyによる分散・Webプログラミング
require 'rinda/ring'
require 'rinda/tuplespace'

DRb.start_service

ts = Rinda::TupleSpace.new
place = Rinda::RingServer.new(ts)
DRb.thread.join
