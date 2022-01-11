# YARV Maniacs 【第 2 回】 VM ってなんだろう
# https://magazine.rubyist.net/articles/0007/0007-YarvManiacs.html

module RubyMaVM
  class Instruction
    attr_reader :code, :ops

    def initialize(code, ops)
      @code = code
      @ops = ops
    end

    def inspect
      "#{code} <#{ops.join(',')}>"
    end
  end

  class Label
    @@id = 0

    def initialize(label)
      @label = label
      @pos = -1
      @id = @@id += 1
    end

    alias to_s inspect
  end

  class Evaluator
    def initialize
      @stack = []
      @pc = 0
    end

    def evaluate(sequence)
      # WIP
    end

    def dispatch(insn)
      # WIP
    end

    def push(obj)
      # WIP
    end

    def pop
      # WIP
    end
  end

  class Parser
    def self.parse(program)
      # WIP
    end
  end
end

if $0 == __FILE__
  program = << EOP
    push 1
  :label
    push 1
    add
    dup
    push 10000
    bigger
    if :label
  EOP

  parsed_program = RubyMaVM::Parser.parse(program)
  parsed_program.each_with_index { |insn, idx|
    puts "#{'%04d' % idx}\t#{insn.inspect}"
  }

  result = RubyMaVM::Evaluator.new.evaluate(parsed_program)
  puts result
end
