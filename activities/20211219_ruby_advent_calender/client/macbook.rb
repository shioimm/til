require "drb"

DRb.start_service("druby://#{ENV['LOCAL_HOST_ADDRESS']}:8081")
puts "Start server process on #{DRb.uri}"

uri = "druby://#{ENV["REMOTE_HOST_ADDRESS"]}:8080"
kvs = DRbObject.new_with_uri(uri)

puts "[LOG] uri = #{uri}"
puts "[LOG] kvs = DRbObject.new_with_uri(uri)"
puts "[LOG] kvs:\n#{kvs}"

kvs["greeting"] = "Hello from MacBook"

puts "[LOG] kvs['greeting'] = 'Hello from MacBook'"
puts "[LOG] kvs:\n#{kvs}"

sleep 1

kvs["stdout"] = $stdout

puts "[LOG] kvs['stdout'] = $stdout"
puts "[LOG] kvs:\n#{kvs}"
puts "[LOG] sleep"; sleep
