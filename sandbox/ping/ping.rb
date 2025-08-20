class Ping
  def self.execute!(dest)
    new(dest).execute!
  end

  def initialize(dest)
    @dest = dest
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
