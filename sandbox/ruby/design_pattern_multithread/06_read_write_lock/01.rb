# Java言語で学ぶデザインパターン入門 マルチスレッド編 第6章

class Data
  def initialize(size)
    @buffer = Array.new(size, '*').join
    @lock = ReadWriteLock.new
  end

  def read
    @lock.read_lock

    begin
      read!
    ensure
      @lock.read_unlock
    end
  end

  def write(c)
    @lock.write_lock

    begin
      write!(c)
    ensure
      @lock.write_unlock
    end
  end

  private

    def read!
      new_buf = @buffer.chars.each_with_object([]) do |b, arr|
        arr << b
      end.join

      slowly
      new_buf
    end

    def write!(c)
      @buffer = @buffer.chars.each_with_object([]) do |_, arr|
        arr << c
      end.join

      slowly
    end

    def slowly
      sleep 0.5
    end
end

class Writer
  def initialize(data, filler)
    @data, @filler = data, filler
    @index = 0
  end

  def run
    loop do
      @data.write(next_char)
      sleep rand
    end
  end

  private

    def next_char
      c = @filler[@index]
      @index += 1
      @index = 0 if @index >= @filler.size
      c
    end
end

class Reader
  def initialize(data)
    @data = data
  end

  def run
    loop do
      read_buf = @data.read
      puts "#{Thread.current.name} reads #{read_buf}"
    end
  end
end

class ReadWriteLock
  def initialize
    @reading_readers = 0 # 実際に読んでいる最中のスレッドの数
    @waiting_writers = 0 # 書き込み待ちのスレッドの数
    @writing_writers = 0 # 実際に書いているスレッドの数(0 or 1)
    @prefer_writers  = true # true = Write優先 / false = Read優先
    @m = Mutex.new
    @cond = ConditionVariable.new
  end

  def read_lock
    @m.synchronize do
      while @writing_writers > 0 || (@prefer_writers && @waiting_writers > 0)
        @cond.wait(@m)
      end

      @reading_readers += 1
    end
  end

  def read_unlock
    @m.synchronize do
      @reading_readers -= 1
      @prefer_writers = true
      @cond.broadcast
    end
  end

  def write_lock
    @m.synchronize do
      @waiting_writers += 1

      begin
        while @reading_readers > 0 || @writing_writers > 0
          @cond.wait(@m)
        end
      ensure
        @waiting_writers -= 1
      end

      @writing_writers += 1
    end
  end

  def write_unlock
    @m.synchronize do
      @writing_writers -= 1
      @prefer_writers = false
      @cond.broadcast
    end
  end
end

data = Data.new(10)

rs = 6.times.map do |i|
  Thread.new do
    Thread.current.name = "Thread #{i}"
    Reader.new(data).run
  end
end

ws = 6.times.map do |i|
  Thread.new do
    Writer.new(data, ('a'..'z').to_a).run
  end
end

rs.each(&:join)
ws.each(&:join)
