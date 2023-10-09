# 参照: dRubyによる分散・Webプログラミング
require 'drb/drb'

class Reminder
  def initialize
    @item = {}
    @serial = 0
  end

  def [](key)
    @item[key]
  end

  def add(str)
    @serial += 1
    @item[@serial] = str
    @serial
  end

  def delete(key)
    @item.delete(key)
  end

  def to_a
    @item.keys.sort.collect do |k|
      [k, @item[k]]
    end
  end
end

# $ irb --prompt simple -r ./practices/druby/druby_book/reminder0.rb -r drb/drb
# >> front = Reminder.new
# >> DRb.start_service('druby://localhost:12345', front)

# >> r = DRbObject.new_with_uri('druby://localhost:12345')
# >> r.to_a
# >> r.add('13:00 ミーティング')
# >> r.add('17:00 進捗報告')
# >> r.to_a
