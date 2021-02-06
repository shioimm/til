# Java言語で学ぶデザインパターン入門 マルチスレッド編 第1章

class User
  def initialize(gate, name, address)
    @gate, @name, @address = gate, name, address
  end

  def run
    puts "#{@name} BEGIN"

    loop do
      @gate.pass(@name, @address)
      puts "#{@name} passed the gate."
    end
  end
end

class Gate
  @@counter = 0
  @@name = 'Nobody'
  @@address = 'Nowhere'
  @@mutex = Mutex.new

  def pass(name, address)
    @@mutex.synchronize do
      @@counter += 1
      @@name = name
      @@address = address

      check
    end
  end

  private

    def to_string
      @@mutex.synchronize do
        "#{@@counter}: #{@@name}, #{@@address}"
      end
    end

    def check
      return if @@name.start_with? @@address[0]

      # Rubyの場合はGVLの働きによりこの行が実行されることはない
      puts "*** BROKEN *** No. #{to_string}"
    end
end

puts 'Testing gate, hit CTRL+C to exit.'

GATE = Gate.new
threads = []
threads << Thread.new { User.new(GATE, 'Alice', 'Alaska').run }
threads << Thread.new { User.new(GATE, 'Bobby', 'Brazil').run }
threads << Thread.new { User.new(GATE, 'Chris', 'Canada').run }

threads.each(&:join)
