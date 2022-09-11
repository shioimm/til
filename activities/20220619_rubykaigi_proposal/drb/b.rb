require "drb"

DRb.start_service
foo = DRbObject.new_with_uri("druby://localhost:8082")
p foo.greeting("dRuby")
p foo.sum(1, 2)
p foo.with_block { "with block" }
