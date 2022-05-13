require 'drb'

DRb.start_service
foo = DRbObject.new_with_uri('druby://localhost:8080')
puts foo.greeting
