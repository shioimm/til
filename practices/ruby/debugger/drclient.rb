require 'drb'

uri = "druby://#{ENV["REMOTE_HOST_ADDRESS"]}:8080"
obj = DRbObject.new_with_uri(uri)

p obj.inspect
