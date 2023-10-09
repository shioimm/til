# 参照: dRubyによる分散・Webプログラミング
require 'drb/drb'
require 'monitor'

class Reminder
  include MonitorMixin

  def initialize
    super()
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

# $ irb --prompt simple -r drb/drb -r monitor
# >> m = Monitor.new
# => #<Monitor:0x00007fcf6c0ef900>
# >> DRb.start_service('druby://localhost:12345', m)
# >> m.mon_enter
# => nil
# >> m.mon_exit
# => nil

# $ irb --prompt simple -r drb/drb
# >> DRb.start_service
# >> m = DRbObject.new_with_uri('druby://localhost:12345')
# => #<DRb::DRbObject:0x00007fcc6a949448 @ref=nil, @uri="druby://localhost:12345">
# >> m.synchronize { puts 'hello' }
# hello (mon_enterしたスレッドがmon_exitが呼ばれるまでブロック)
# >> m.synchronize { m.synchronize { puts 'nest' } }
# (最初のsynchronizeを行うスレッドとブロック内でsynchronizeを実行するスレッドが異なるためブロック)
# (dRubyではブロック付きメソッドのメソッド呼び出しをしたスレッドとブロックを実行するスレッドが異なる)
