require "drb"

DRb.start_service
uri = "druby://localhost:54000"
it = DRbObject.new_with_uri(uri)
it.greeting
