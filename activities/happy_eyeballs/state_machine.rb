require_relative './state_machine_sample'

INPUT =%i[A B]
SINGLE_RULE_STATES = %i[
  start_ipv6_dns_query
  finish_ipv6_dns_query
  resolution_delay
  finish_ipv4_dns_query
  connection_attempt_delay
]

class StateMachine
  rulebook = Rulebook.new([
    Rulebook::Rule.new(:start, :A, :start_ipv6_dns_query),
    Rulebook::Rule.new(:start, :B, :start_ipv4_dns_query),

    Rulebook::Rule.new(:start_ipv6_dns_query, :A, :finish_ipv6_dns_query),

    Rulebook::Rule.new(:finish_ipv6_dns_query, :A, :prepare_connection_attempt),

    Rulebook::Rule.new(:start_ipv4_dns_query,:A, :resolution_delay),
    Rulebook::Rule.new(:start_ipv4_dns_query,:B, :finish_ipv4_dns_query),

    Rulebook::Rule.new(:resolution_delay, :A, :finish_ipv4_dns_query),

    Rulebook::Rule.new(:finish_ipv4_dns_query, :A, :prepare_connection_attempt),

    Rulebook::Rule.new(:prepare_connection_attempt, :A, :connection_attempt_delay),
    Rulebook::Rule.new(:prepare_connection_attempt, :B, :start_connection_attempt),

    Rulebook::Rule.new(:connection_attempt_delay, :A, :start_connection_attempt),

    Rulebook::Rule.new(:start_connection_attempt, :A, :success),
    Rulebook::Rule.new(:start_connection_attempt, :B, :failure),
  ])
  @dfa = DFA.new(:start, [:success, :failure], rulebook)

  def initialize(initial_input)
    @initial_input = initial_input
  end

  def run
    puts "#{no} #{dfa.current_state} -> #{@initial_input}"
    read @initial_input

    loop do
      next_input = input
      puts "#{no} -> #{dfa.current_state} -> #{next_input}"
      read(next_input)
      break if finishable?
    end

    puts "#{no} -> #{dfa.current_state}"
  end

  private

  def no
    "(#{INPUT.index(@initial_input) + 1})"
  end

  def input
    if SINGLE_RULE_STATES.include? dfa.current_state
      :A
    else
      INPUT.sample
    end
  end


  def dfa
    self.class.instance_variable_get(:@dfa)
  end

  def read(input)
    dfa.update_current_state!(input)
  end

  def finishable?
    dfa.acceptable?
  end
end

StateMachine.new(:A).run
