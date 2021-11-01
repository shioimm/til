require 'drb'

DRb.start_service('druby://:8080', {})
puts "Start server on #{DRb.uri}"

sleep 1 until DRb.front['stdout']
DRb.front['stdout'].puts "Hello from server"
