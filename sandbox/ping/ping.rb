def ping(dest)
  agv = 1 / 1 # WIP
  puts "RTT (Avg): #{agv}ms"
end

dest = ARGV.first

begin
  raise "Missing ping target" if dest.nil?

  ping(dest)
rescue => e
  puts e.full_message
end
