require 'drb'

DRb.start_service
foo = DRbObject.new_with_uri('druby://localhost:8080')
puts foo.greeting("dRuby")
puts foo.add(0)
puts foo.with_block { 'with block' }