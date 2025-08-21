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
    @count.times do |i|
      @total_time += 1 # WIP
      @total_count += 1 # WIP
    end

    puts "RTT (Avg): #{@total_time / @total_count}ms"
  end

  private

  def send
    # WIP
  end

  def recv
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
