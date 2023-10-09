# 参照: dRubyによる分散・Webプログラミング

class Foo
  def initialize(name)
    @name = name
  end
  attr_accessor :name
end

# Marshal.dump可能なオブジェクトはノード1からノード2へ値渡しされる
# Marshal.dump不可能なオブジェクトはノード1からノード2へ参照渡しされる
# Marshal.dump可能なオブジェクトを参照渡しにする場合はDRbUndumpedでオブジェクトを拡張する

# $ irb --prompt simple -r ./practices/druby/druby_book/foo.rb -r drb/drb
# >> front = {}
# => {}
# >> DRb.start_service('druby://:12345', front)
# >> foo = Foo.new('Foo1')
# >> foo.name
# => "Foo1"
# >> foo.extend DRbUndumped
# >> foo.name
# => "Foo2"
# >> bar = Foo.new('Bar1')
# ?> class Foo
# ?>   include DRbUndumped
# >> end
# >> front[:bar] = bar
# => #<Foo:0x00007fe33382c490 @name="Bar1">
# >> bar.name
# => "Bar1"
# >> bar.name
# => "Bar2"

# $ irb --prompt simple -r ./practices/druby/druby_book/foo.rb -r drb/drb
# >> DRb.start_service
# >> there = DRbObject.new_with_uri("druby://localhost:12345")
# => #<DRb::DRbObject:0x00007fb9ff2a0588 @ref=nil, @uri="druby://localhost:12345">
# >> there[:foo].name
# => "Foo1"
# >> there[:foo].name = 'Foo2'
# => "Foo2"
# >> there[:foo].name
# => "Foo1"
# >> there[:foo].name = 'Foo2'
# => "Foo2"
# >> there[:foo]
# => #<DRb::DRbObject:0x00007fb9ff2509e8 @ref=260, @uri="druby://127.0.0.1:12345">
# >> there[:foo].name
# => "Foo2"
# >> there[:bar].name
# => "Bar1"
# >> there[:bar].name = 'Bar2'
# => "Bar2"
# >> there[:bar].name
# => "Bar2"

# ノード1で未定義のオブジェクトがノード2から値渡しでセットされた場合
# (ノード1がMarshal.loadに失敗した場合)
# ノード1が受け取るオブジェクトはDRbUnknownオブジェクトになる

# irb --prompt simple -r drb/drb
# >> front = {}
# => {}
# >> DRb.start_service('druby://:12345', front)
# >> front[:foo]
# => #<DRb::DRbUnknown:0x00007faf21203848 @buf="\x04\bo:\bFoo\x06:\n@nameI\"\tFoo1\x06:\x06ET", @name="Foo">
# >> front[:foo].buf
# => "\x04\bo:\bFoo\x06:\n@nameI\"\tFoo1\x06:\x06ET"
# >> front[:foo].name
# => "Foo"
# >> front[:foo].reload
# => #<DRb::DRbUnknown:0x00007faf21986318 @buf="\x04\bo:\bFoo\x06:\n@nameI\"\tFoo1\x06:\x06ET", @name="Foo">

# $ irb --prompt simple -r ./practices/druby/druby_book/foo.rb -r drb/drb
# >> DRb.start_service
# >> DRbObject.new_with_uri("druby://localhost:12345")
# => #<DRb::DRbObject:0x00007fc3bb99d1e0 @ref=nil, @uri="druby://localhost:12345">
# >> there = DRbObject.new_with_uri("druby://localhost:12345")
# => #<DRb::DRbObject:0x00007fc3bb97f410 @ref=nil, @uri="druby://localhost:12345">
# >> foo = Foo.new('Foo1')
# => #<Foo:0x00007fc3bf095ee0 @name="Foo1">
# >> there[:foo] = foo
# => #<Foo:0x00007fc3bf095ee0 @name="Foo1">
# >> bar = there[:foo]
# => #<Foo:0x00007fc3bb9940b8 @name="Foo1">
# >> foo.__id__ == bar.__id__
# => false

# $ irb --prompt simple -r drb/drb
# >> DRb.start_service
# >> there = DRbObject.new_with_uri('druby://localhost:12345')
# => #<DRb::DRbObject:0x00007fd14d89e8a8 @ref=nil, @uri="druby://localhost:12345">
# >> unknown = there[:foo]
# => #<DRb::DRbUnknown:0x00007fd14d8b66b0 @buf="\x04\bo:\bFoo\x06:\n@nameI\"\tFoo1\x06:\x06ET", @name="Foo">
# >> unknown.name
# => "Foo"
# >> require_relative './practices/druby/druby_book/foo.rb'
# => true
# >> unknown.reload
# => #<Foo:0x00007fd14902ddf8 @name="Foo1">
# >> foo = there[:foo]
# => #<Foo:0x00007fd14d8e98f8 @name="Foo1">
