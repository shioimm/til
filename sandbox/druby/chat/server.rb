require "drb"

clients = { client1: nil, client2: nil }

DRb.start_service('druby://localhost:54320', clients)

sleep
