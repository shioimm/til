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

  def pass(name, address)
    @@counter += 1
    @@name = name
    @@address = address

    check
  end

  private

    def to_string
      "#{@@counter}: #{@@name}, #{@@address}"
    end

    def check
      return if @@name.start_with? @@address[0]

      # Rubyの場合はGVLの働きによりこの行が実行されることはない
      puts "*** BROKEN *** No. #{@@counter}: #{@@name}, #{@@address}"
    end
end

puts 'Testing gate, hit CTRL+C to exit.'

GATE = Gate.new
threads = []
threads << Thread.new { User.new(GATE, 'Alice', 'Alaska').run }
threads << Thread.new { User.new(GATE, 'Bobby', 'Brazil').run }
threads << Thread.new { User.new(GATE, 'Chris', 'Canada').run }

threads.each(&:join)
