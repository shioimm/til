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
    agv = 1 / 1 # WIP
    puts "RTT (Avg): #{agv}ms"
  end
end

dest = ARGV.first

begin
  raise "Missing ping target" if dest.nil?

  Ping.execute!(dest)
rescue => e
  puts e.full_message
end
