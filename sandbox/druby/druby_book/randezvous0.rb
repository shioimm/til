# 参照: dRubyによる分散・Webプログラミング
require 'drb/drb'
require 'monitor'

class Randezvous
  include MonitorMixin

  def initialize
    super
    @arrived_cond = new_cond
    @removed_cond = new_cond
    @box = nil
    @arrived = false
  end

  def send(obj)
    synchronize do
      @arrived_cond.wait_while { @arrived }
      @arrived = true
      @box = obj
      @arrived_cond.broadcast
      @removed_cond.wait
    end
  end

  def recv
    synchronize do
      @arrived_cond.wait_until { @arrived }
      @arrived = false
      @removed_cond.broadcast
      @box
    end
  end
end
