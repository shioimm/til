class Rulebook
  class Rule
    attr_reader :current_state, :input, :next_state

    def initialize(current_state, input, next_state)
      @current_state = current_state
      @input = input
      @next_state = next_state
    end
  end

  def initialize(rules)
    @rules = rules
  end

  def next_state(state, input)
    @rules.find { |rule| rule.current_state == state && rule.input == input }.next_state
  end
end

class DFA
  attr_reader :current_state

  def initialize(current_state, end_states, rulebook)
    @current_state = current_state
    @end_states = end_states
    @rulebook = rulebook
  end

  def acceptable?
    @end_states.include?(@current_state)
  end

  def update_current_state!(input)
    @current_state = @rulebook.next_state(@current_state, input)
  end
end

# class StateMachine
#   INPUT = %i[white black]
#
#   class << self
#     def run
#       new.run
#     end
#   end
#
#   def initialize
#     rulebook = Rulebook.new([
#       Rulebook::Rule.new(:start, :white, :A),     Rulebook::Rule.new(:start, :black, :B),
#       Rulebook::Rule.new(:A,     :white, :C),     Rulebook::Rule.new(:A,     :black, :B),
#       Rulebook::Rule.new(:B,     :white, :D),     Rulebook::Rule.new(:B,     :black, :E),
#       Rulebook::Rule.new(:C,     :white, :start), Rulebook::Rule.new(:C,     :black, :F),
#       Rulebook::Rule.new(:D,     :white, :F),     Rulebook::Rule.new(:D,     :black, :start),
#       Rulebook::Rule.new(:E,     :white, :end),   Rulebook::Rule.new(:E,     :black, :start),
#       Rulebook::Rule.new(:F,     :white, :start), Rulebook::Rule.new(:F,     :black, :end),
#     ])
#     @dfa = DFA.new(:start, [:end], rulebook)
#   end
#
#   def run
#     puts '-- start --'
#
#     begin
#       input = INPUT.sample
#       puts input
#     end until read(input).then { finishable? }
#
#     puts '-- finish --'
#   end
#
#   private
#
#   def read(input)
#     @dfa.update_current_state!(input)
#   end
#
#   def finishable?
#     @dfa.acceptable?
#   end
# end
#
# StateMachine.run
