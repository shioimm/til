# 参照: dRubyによる分散・Webプログラミング
require 'rinda/tuplespace'

class RDStream
  def initialize(ts = Rinda::Tuplespace.new, name = nil)
    @ts = ts
    @name = name
    @ts.write([@name, 'tail', 0])
    @ts.write([@name, 'head', 0])
  end

  def write(value)
    tuple = @ts.take([@name, 'tail', nil])
    tail = tuple[2] + 1
    @ts.write([@name, tail, value])
    @ts.write([@name, 'tail', tail])
  end

  def take
    tuple = @ts.take([@name, 'head', nil])
    head = tuple[2]
    tuple = @ts.take([@name, head, nil])
    @ts.write([@name, 'head', head + 1])
  end
end
