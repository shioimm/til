# 参照: dRubyによる分散・Webプログラミング
require 'monitor'

class Reminder
  include MonitorMixin

  def initialize
    super
    @item = {}
    @serial = 0
  end

  def [](key)
    @item[key]
  end

  def add(str)
    synchronize do
      @serial += 1
      @item[key] = str
      @serial
    end
  end

  def delete(key)
    synchronize do
      @item.delete(key)
    end
  end

  def to_a
    synchronize do
      @item.keys.sort.collect do |k|
        [k, @item[k]]
      end
    end
  end
end

if __FILE__ == $0
  require 'drb/drb'
  front = Reminder.new
  DRb.start_service('druby://localhost:12345', front)
  puts DRb.uri
  DRb.thread.join
end
