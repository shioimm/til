# 参照: dRubyによる分散・Webプログラミング
require 'rinda/tuplespace'

class Barrier
  def initialize(ts = Rinda::Tuplespace.new, n = 0, name = nil)
    @ts = ts
    @name = name
    @ts.write([key, n])
  end

  def key
    @name
  end

  def synchronize
    tmp, val = @ts.write([key, nil])
    @ts.write([key, val - 1])
    @ts.read(key, 0)
  end
end
