require 'drb'

queue = Queue.new
DRb.start_service('druby://:12345', queue)
puts "Start server on #{DRb.uri}"
sleep
