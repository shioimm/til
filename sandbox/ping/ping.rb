require "socket"

ECHO_HEADER_SIZE = 8

class Ping
  def self.execute!(dest)
    new(dest).execute!
  end

  def initialize(dest)
    @dest = dest
    @size = 64
    @count = 5
    @timeout = 1
    @total_time = 0
    @total_count = 0
  end

  def execute!
    @count.times.each.with_index(1) do |seq|
      send_echo
      receive_reply
      @total_time += 1 # WIP
      @total_count += 1 # WIP

      sleep 1
    end

    puts "RTT (Avg): #{@total_time / @total_count}ms"
  end

  private

  def send_echo
    # WIP
  end

  def receive_reply
    # WIP
  end
end

dest = ARGV.first

begin
  raise "Missing ping target" if dest.nil?

  Ping.execute!(dest)
rescue => e
  puts e.full_message
end
