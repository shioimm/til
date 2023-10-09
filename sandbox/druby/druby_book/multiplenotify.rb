# 参照: dRubyによる分散・Webプログラミング
require 'drb/drb'
require 'rinda/rinda'
require 'rinda/tuplespace'

class MultipleNotify
  def initialize(ts, event, arr)
    @queue = Queue.new
    @entry = []
    arr.each do |pattern|
      make_listener(ts, event, pattern)
    end
  end

  def pop
    @queue.pop
  end

  def make_listener(ts, event, pattern)
    entry = ts.notify(event, pattern)
    @entry.push entry

    Thread.new do
      entry.each do |ev|
        @queue.push ev
      end
    end
  end
end

mn = MultipleNotify.new(ts, nil, [['test', nil], ['name', 'rwiki', nil]])

while true
  mn.pop
end
