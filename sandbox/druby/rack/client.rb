require 'drb'

DRb.start_service
server = DRbObject.new_with_uri('druby://localhost:9292')
server.get
