require 'drb'

DRb.start_service
foo = DRbObject.new_with_uri('druby://localhost:8082')
puts foo.greeting("dRuby")
puts foo.add(1)
# puts foo.with_block { 'with block' }
