# 参照: drubyによる分散・webプログラミング
require 'drb/drb'

class DumbIdConv < DRb::DRbIdConv
  def initialize
    @table = Hash.new
  end

  attr_reader :table

  def to_id(obj)
    ref = super(obj)
    @table[ref] = obj
    ref
  end
end

# $ irb -r ./practices/druby/druby_book/dumbidconv.rb
# irb(main):001:0> $dumb = DumbIdConv.new
# irb(main):002:0> DRb.start_service('druby://localhost:12345', {}, { idconv: $dumb })
# irb(main):003:0> DRb.front['main-thread'] = Thread.current
# irb(main):005:0> $dumb.table
# => {260=>#<Thread:0x00007fdce087bc38 run>}

# $ irb -r drb
# irb(main):001:0> DRb.start_service
# irb(main):002:0> ro = DRbObject.new_with_uri('druby://localhost:12345')
# => #<DRb::DRbObject:0x00007f897e810ce0 @ref=nil, @uri="druby://localhost:12345">
# irb(main):003:0> ro.keys
# => ["main-thread"]
# irb(main):004:0> ro['main-thread']
# => #<DRb::DRbObject:0x00007f8979989680 @ref=260, @uri="druby://localhost:12345">
# irb(main):005:0> ro['main-thread'].status
# => "sleep"
