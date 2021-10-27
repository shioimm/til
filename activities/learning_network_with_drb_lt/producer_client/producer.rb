require 'drb'

DRb.start_service
queue = DRbObject.new_with_uri(ARGV.shift)
queue.push 'Hello'
puts 'Finished to push'
