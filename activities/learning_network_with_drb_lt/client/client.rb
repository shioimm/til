require 'drb'

DRb.start_service("druby://#{ENV['LOCAL_HOST_ADDRESS']}:8081")
uri = "druby://#{ENV['REMOTE_HOST_ADDRESS']}:8080"

puts '[LOG] kvs = DRbObject.new_with_uri(uri)'
kvs = DRbObject.new_with_uri(uri)

puts '[LOG] puts kvs'
puts kvs

puts '[LOG] kvs["greeting"] = "Hello"'
kvs['greeting'] = 'Hello'

puts '[LOG] puts kvs'
puts kvs

puts '[LOG] kvs["stdout"] = $stdout'
kvs['stdout'] = $stdout

puts '[LOG] puts kvs'
puts kvs

puts '[LOG] sleep'
sleep
