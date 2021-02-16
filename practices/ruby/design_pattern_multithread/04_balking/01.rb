# Java言語で学ぶデザインパターン入門 マルチスレッド編 第4章

class Data
  def initialize(filename, content)
    @filename, @content = filename, content
    @changed = false
    @m = Mutex.new
  end

  def change(content)
    @m.synchronize do
      @content = content
      @changed = true
    end
  end

  def save
    return unless @changed

    @m.synchronize do
      save!
      @changed = false
    end
  end

  private

    def save!
      puts "#{Thread.current.name} calls #save!, content = #{@content}"

      File.open(@filename, File::RDWR | File::CREAT) do |f|
        f.write @content
      end
    end
end

class Server
  def initialize(data)
    @data = data
  end

  def run
    loop do
      @data.save
      sleep 1
    end
  end
end

class Changer
  def initialize(data)
    @data = data
  end

  def run
    (1..).each do |i|
      @data.change("No. #{i}")
      sleep rand
      @data.save
    end
  end
end

data = Data.new('data.txt', '(empty)')

Thread.new do
  Changer.new(data).run
end.join

Thread.new do
  Server.new(data).run
end.joim
