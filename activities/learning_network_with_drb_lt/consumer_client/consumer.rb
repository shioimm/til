require 'drb'

DRb.start_service
queue = DRbObject.new_with_uri(ARGV.shift)
puts 'Start to pop...'
puts queue.pop
