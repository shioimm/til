require 'drb'

kvs      = {}
last_kvs = {}

DRb.start_service("druby://#{ENV['LOCAL_HOST_ADDRESS']}:8080", kvs)
puts "Start server process on #{DRb.uri}"

loop do
  if kvs.size > last_kvs.size
    puts "New record has been added:\n#{kvs}"

    new_values = (kvs.values - last_kvs.values)
    new_stdouts = new_values.select { |value| value.respond_to?(:tty?) && value.tty? }

    unless new_stdouts.empty?
      puts "Greet to client: 'Hello from ThinkPad'"
      new_stdouts.each { |new_stdout| new_stdout.puts "Hello from ThinkPad" }
    end

    last_kvs = kvs.dup
  end

  sleep 1
end
