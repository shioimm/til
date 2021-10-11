# 参照: dRubyによる分散・Webプログラミング
require 'drb/drb'
require 'rinda/tuplespace'

DRb.start_service

ts = Rinda::TupleService.new
place = Rinda::RingServer.new(ts)
DRb.thread.join
