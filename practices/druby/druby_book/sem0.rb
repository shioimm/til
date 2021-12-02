# 参照: dRubyによる分散・Webプログラミング
require 'drb/drb'
require 'rinda/tuplespace'

class Sem
  include DRbUndumped

  def initialize(ts = Rinda::Tuplespace.new, n = 0, name = nil)
    @ts = ts
    @name = name || self
    n.times { up }
  end

  attr_reader :name

  def synchronize
    succ = down
    yield
  ensure
    up if succ
  end

  private

    def up
      @ts.write(key)
    end

    def down
      @ts.take(key)
      return true
    end

    def key
      [@name]
    end
end
