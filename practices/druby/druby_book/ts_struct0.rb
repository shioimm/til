# 参照: dRubyによる分散・Webプログラミング
require 'rinda/tuplespace'

class TSStruct
  def initialize(ts = Rinda::Tuplespace.new, name = nil, struct = nil)
    @ts = ts
    @name = name || self

    return unless struct

    struct.each_pair do |key, value|
      @ts.write([key, value])
    end
  end

  attr_reader :name

  def [](key)
    tuple = @ts.read([name, key, nil])
    tuple[2]
  end

  def []=(key, value)
    replace(key) { |old_value| value }
  end

  def replace(key)
    tuple = @ts.take([name, key, nil])
    tuple[2] = yield tuple[2]
  ensure
    @ts.write(tuple) if tuple
  end
end
