# 参照: dRubyによる分散・Webプログラミング
require 'thread'

class Randezvous
  def initialize
    super
    @send_queue = SizedQueue.new(1)
    @recv_queue = SizedQueue.new(1)
  end

  def send(obj)
    @send_queue.enq obj
    @recv_queue.deq
  end

  def recv
    @send_queue.deq
  rescue
    @recv_queue.enq nil
  end
end
