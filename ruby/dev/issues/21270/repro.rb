# https://bugs.ruby-lang.org/issues/21270

require "fiber"
require "socket"

# ref test/fiber/scheduler.rb
class Scheduler
  def initialize
    @fiber = Fiber.current
    @readable = {}
    @writable = {}
    @waiting = {}
    @closed = false
    @lock = Thread::Mutex.new
    @ready = []
    @urgent = IO.pipe
  end

  attr :readable
  attr :writable
  attr :waiting

  def next_timeout
    _fiber, timeout = @waiting.min_by{|key, value| value}

    if timeout
      offset = timeout - current_time

      if offset < 0
        return 0
      else
        return offset
      end
    end
  end

  def run
    # $stderr.puts [__method__, Fiber.current].inspect

    while @readable.any? or @writable.any? or @waiting.any?
      # May only handle file descriptors up to 1024...
      readable, writable = IO.select(@readable.keys + [@urgent.first], @writable.keys, [], next_timeout)

      # puts "readable: #{readable}" if readable&.any?
      # puts "writable: #{writable}" if writable&.any?

      selected = {}

      readable&.each do |io|
        if fiber = @readable.delete(io)
          @writable.delete(io) if @writable[io] == fiber
          selected[fiber] = IO::READABLE
        elsif io == @urgent.first
          @urgent.first.read_nonblock(1024)
        end
      end

      writable&.each do |io|
        if fiber = @writable.delete(io)
          @readable.delete(io) if @readable[io] == fiber
          selected[fiber] = selected.fetch(fiber, 0) | IO::WRITABLE
        end
      end

      selected.each do |fiber, events|
        fiber.transfer(events)
      end

      if @waiting.any?
        time = current_time
        waiting, @waiting = @waiting, {}

        waiting.each do |fiber, timeout|
          if fiber.alive?
            if timeout <= time
              fiber.transfer
            else
              @waiting[fiber] = timeout
            end
          end
        end
      end

      if @ready.any?
        ready = nil

        @lock.synchronize do
          ready, @ready = @ready, []
        end

        ready.each do |fiber|
          fiber.transfer
        end
      end
    end
  end

  def scheduler_close
    close(true)
  end

  def close(internal = false)
    # $stderr.puts [__method__, Fiber.current].inspect

    unless internal
      if Fiber.scheduler == self
        return Fiber.set_scheduler(nil)
      end
    end

    if @closed
      raise "Scheduler already closed!"
    end

    self.run
  ensure
    if @urgent
      @urgent.each(&:close)
      @urgent = nil
    end

    @closed ||= true

    self.freeze
  end

  def current_time
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  def io_wait(io, events, duration)
    # $stderr.puts [__method__, io, events, duration, Fiber.current].inspect

    fiber = Fiber.current

    unless (events & IO::READABLE).zero?
      @readable[io] = fiber
      readable = true
    end

    unless (events & IO::WRITABLE).zero?
      @writable[io] = fiber
      writable = true
    end

    if duration
      @waiting[fiber] = current_time + duration
    end

    @fiber.transfer
  ensure
    @waiting.delete(fiber) if duration
    @readable.delete(io) if readable
    @writable.delete(io) if writable
  end

  def kernel_sleep(duration = nil)
    # $stderr.puts [__method__, duration, Fiber.current].inspect

    self.block(:sleep, duration)

    return true
  end

  def block(blocker, timeout = nil)
    # $stderr.puts [__method__, blocker, timeout].inspect

    fiber = Fiber.current

    @waiting[fiber] = current_time + timeout
    begin
      @fiber.transfer
    ensure
      @waiting.delete(fiber)
    end
  end

  def unblock(blocker, fiber)
    # $stderr.puts [__method__, blocker, fiber].inspect
    # $stderr.puts blocker.backtrace.inspect
    # $stderr.puts fiber.backtrace.inspect

    @lock.synchronize do
      @ready << fiber
    end

    io = @urgent.last
    io.write_nonblock(".")
  end

  def fiber(&block)
    fiber = Fiber.new(blocking: false, &block)

    fiber.transfer

    return fiber
  end
end

# ブロッキング操作の実行をフックにしてスケジューラを起動し、ブロックしないように非同期化する
Fiber.set_scheduler(Scheduler.new)

puts "#{Fiber.current.object_id}: Main fiber"  # Fiber.current = 実行中のFiber

Fiber.schedule do # 新しいFiberを生成してスケジューラへ登録、ブロックせずに戻る
  puts "#{Fiber.current.object_id}: Creating socket"

  # connectで処理をブロック中、スケジューラのio_waitが呼ばれる
  TCPSocket.new("example.com", 12345, fast_fallback: false) # works
  # TCPSocket.new("example.com", 12345, fast_fallback: true) # does not work
  # Socket.tcp("example.com", 12345, fast_fallback: true) # works

  puts "#{Fiber.current.object_id}: Connected" # 接続が成功したタイミングで実行される
end

Fiber.schedule do
  puts "#{Fiber.current.object_id}: Sleeping"
  # スケジューラ がsleepをフックして タイマー登録だけして直ちに別Fiberへ切り替え
  sleep 2
  puts "#{Fiber.current.object_id}: Done sleeping"
end

puts "#{Fiber.current.object_id}: Both fibers started"
# メインFiber実行時点で2つのFiberは未完了でスケジューラにより監視下に置かれている
# メインFiberの実行が終わると、登録済みFiberがなくなるまでイベントループを回し続ける

# 16: Main fiber
# 24: Creating socket
# 40: Sleeping
# 16: Both fibers started
# 40: Done sleeping
