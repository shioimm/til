# 参照: dRubyによる分散・Webプログラミング
require 'rinda/tuplespace'

class RDStream
  def initialize(ts = Rinda::Tuplespace.new, name = nil)
    @ts = ts
    @name = name
    @head = 0
  end

  def read
    tuple = @ts.read([@name, @head, nil])
    @head += 1
    return tuple[2]
  end
end
