# Java言語で学ぶデザインパターン入門 マルチスレッド編 第11章

class TSLog
  attr_reader :name

  def initialize(name, filename)
    @name, @filename = name, filename
  end

  def print(s)
    File.open(@filename, "a+") do |f|
      f.write "#{s}\n"
    end
  end
end

class Log
  @@tslogs = []

  def self.print(s)
    get_tslog.print s
  end

  private

    def self.get_tslog
     tslog = @@tslogs.find { |tslog| Thread.current[:name].eql? tslog.name }

     unless tslog
       tslog = TSLog.new(Thread.current[:name], "#{Thread.current[:name]}-log.txt")
        @@tslogs << tslog
      end

      tslog
    end
end

class Client
  def run
    puts "#{Thread.current[:name]} BEGIN"

    10.times do |i|
      Log.print("i = #{i}")
      sleep 0.1
    end

    Log.print("= End of log =")

    puts "#{Thread.current[:name]} END"
  end
end

cs = 3.times.map do |i|
  Thread.new do
    Thread.current[:name] = i
    Client.new.run
  end
end

cs.each(&:join)
