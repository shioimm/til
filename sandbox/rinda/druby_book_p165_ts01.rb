require 'rinda/tuplespace'

$ts = Rinda::TupleSpace.new
DRb.start_service('druby://:12345', $ts) # druby//:12345 でタプルスペースを提供
puts DRb.uri
# このあとDRb.start_serviceで起動したサーバスレッドはすぐに終了するので起動し続けるためにはjoinで待機が必要
DRb.thread.join
