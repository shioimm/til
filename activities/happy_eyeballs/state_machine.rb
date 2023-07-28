require_relative './state_machine_sample'

STATES = %i[
  start
  start_ipv6_dns_query
  finish_ipv6_dns_query
  start_ipv4_dns_query
  resolution_delay
  finish_ipv4_dns_query
  prepare_connection_attempt
  connection_attempt_delay
  start_connection_attempt
  success
  failure
]

INPUT =%i[A B]

class StateMachine
  class << self
    def run
      new.run
    end
  end

  def initialize
    rulebook = Rulebook.new([
      Rulebook::Rule.new(:start, :A, :start_ipv6_dns_query),
      # WIP
    ])
    @dfa = DFA.new(:start, [:success, :failure], rulebook)
  end

  def run
    puts '-- start --'
    # WIP
    puts '-- finish --'
  end

  private

  def read(input)
    @dfa.update_current_state!(input)
  end

  def finishable?
    @dfa.acceptable?
  end
end

StateMachine.run
