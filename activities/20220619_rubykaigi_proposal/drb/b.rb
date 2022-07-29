require 'drb'

DRb.start_service
foo = DRbObject.new_with_uri('druby://localhost:8082')
puts foo.greeting("dRuby")
puts foo.sum(1, 2)
puts foo.with_block { 'with block' }
