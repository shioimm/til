# 参照: dRubyによる分散・Webプログラミング
require 'rinda/ring'
require 'thread'

class RingNotify
  def initialize(ts, kind, desc=nil)
    @queue = Queue.new
    pattern = [:name, kind, DRbObject, desc]
    open_stream(ts, pattern)
  end

  def pop
    @queue.pop
  end

  def each
    while tuple = @queue.pop
      yield tuple
    end
  end

  private

    def open_stream(ts, pattern)
      @notifier = ts.notify('write', pattern)

      ts.read_all(pattern).each do |tuple|
        @queue.push tuple
      end

      @writer = writer_thread
    end

    def writer_thread
      Thread.start do
        begin
          @notifier.each do |event, tuple|
            @queue.push tuple
          end
        rescue
          @queue.push nil
        end
      end
    end
end
