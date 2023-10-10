# 参照: dRubyによる分散・Webプログラミング
require 'rinda/tuplespace'

class Stream
  def initialize(ts = Rinda::Tuplespace.new, name = nil)
    @ts = ts
    @name = name
    @ts.write([name, 'tail', 0])
  end

  attr_reader :name

  def write(value)
    tuple = @ts.take([name, 'tail', nil])
    tail = tuple[2] + 1
    @ts.write([name, tail, value])
    @ts.write([name, 'tail', tail])
  end
end
