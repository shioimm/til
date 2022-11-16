class HEStateMachine
  def initialize
    @state       = :start
    @transitions = transitions
  end

  private

  def transitions
    transitions = Hash.new

    transitions[] = { :start => :IPv6_getaddrinfo_finished }
    transitions[] = { :start => :IPv4_getaddrinfo_finished }
    transitions[] = { :IPv6_getaddrinfo_finished => :success }
    transitions[] = { :IPv6_getaddrinfo_finished => :IPv4_getaddrinfo_finished }
    transitions[] = { :IPv6_getaddrinfo_finished => :IPv6_getaddrinfo_finished }
    transitions[] = { :IPv4_getaddrinfo_finished => :IPv4_getaddrinfo_and_RESOLUTION_DELAY_finished }
    transitions[] = { :IPv4_getaddrinfo_finished => :IPv6_getaddrinfo_finished }
    transitions[] = { :IPv4_getaddrinfo_and_RESOLUTION_DELAY_finished => :success }
    transitions[] = { :IPv4_getaddrinfo_and_RESOLUTION_DELAY_finished => :IPv6_IPv4_getaddrinfo_finished }
    transitions[] = { :IPv4_getaddrinfo_and_RESOLUTION_DELAY_finished => :IPv4_getaddrinfo_and_RESOLUTION_DELAY_finished }
    transitions[] = { :IPv6_IPv4_getaddrinfo_finished => :success }
    transitions[] = { :IPv6_IPv4_getaddrinfo_finished => :IPv6_IPv4_getaddrinfo_finished }
    transitions[] = { :IPv6_IPv4_getaddrinfo_finished => :error }
  end
end
