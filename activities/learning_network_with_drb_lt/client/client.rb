require 'drb'

DRb.tart_service("druby://#{ENV['YOURHOST']}:8081")
uri = ARGV.shift

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
