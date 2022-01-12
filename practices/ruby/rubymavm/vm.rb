# YARV Maniacs 【第 2 回】 VM ってなんだろう
# https://magazine.rubyist.net/articles/0007/0007-YarvManiacs.html

module RubyMaVM
  class Instruction
    attr_reader :code, :ops

    def initialize(code, ops)
      @code = code
      @ops  = ops
    end

    def inspect
      "#{code} <#{ops.join(',')}>"
    end
  end

  class Label
    attr_accessor :pos

    @@id = 0

    def initialize(label)
      @label = label
      @pos   = -1
      @id    = (@@id += 1)
    end

    def inspect
      "#{@label} <#{@id}@#{@pos}>"
    end
    alias to_s inspect
  end

  class Evaluator
    def initialize
      @stack = []
      @pc    = 0
    end

    def evaluate(sequence)
     while insn = sequence[@pc]
       dispatch(insn)
     end
     @stack[0]
    end

    def dispatch(insn)
      case insn.code
      when :nop
      when :push    then push(insn.ops[0])
      when :pop     then pop
      when :dup     then (popped = pop) && push(popped) && push(popped)
      when :add     then push(pop + pop)
      when :sub     then push(pop - pop)
      when :mul     then push(pop * pop)
      when :div     then push(pop / pop)
      when :not     then push(!pop)
      when :smaller then push(pop < pop)
      when :bigger  then push(pop > pop)
      when :goto    then (@pc = insn.ops[0].pos) && return
      when :if      then pop && (@pc = insn.ops[0].pos) && return
      else          raise "Unknown Opcode: #{insn}"
      end
      @pc += 1
    end

    def push(obj)
      @stack.push(obj)
    end

    def pop
      @stack.pop
    end
  end

  class Parser
    def self.parse(program)
      pc     = 0
      labels = {}
      insns  = program.each_line.map { |line|
        line = line.strip
        insn = []

        if /\A:\w+\z/ =~ line # ラベルの場合
          label = $~[0].intern
          unless lobj = labels[label]
            lobj = ::RubyMaVM::Label.new(label)
            labels[label] = lobj
          end
          next lobj
        end

        while line.size > 0
          case line
          when /\A:[a-z]+/ # ラベル
            label = $~[0].intern
            unless lobj = labels[label]
              lobj = ::RubyMaVM::Label.new(label)
              labels[label] = lobj
            end
            insn << lobj
          when /\A\s+/, /\A\#.*/ # スペース
          when /\A[a-z]+/ then insn << $~[0].intern # 命令
          when /\A\d+/    then insn << $~[0].to_i   # 引数
          else raise "Parse Error: #{line}"
          end
          line = $~.post_match # 次にパースを行う行
        end
        insn.size > 0 ? insn : nil
      }

      insns.compact.map { |insn|
        if insn.kind_of?(::RubyMaVM::Label)
          insn.pos = pc
          nil
        else
          pc += 1
          ::RubyMaVM::Instruction.new(insn[0], insn[1..-1])
        end
      }.compact # [push <1>, push <1>, add <>, dup <>, push <10000>, bigger <>, if <:label <1@1>>]
    end
  end
end

if $0 == __FILE__
  program = <<-EOP
    push 1
    :label
    push 1
    add
    dup
    push 100000
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
