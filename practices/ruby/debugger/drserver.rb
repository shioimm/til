require 'drb'

class C
  def inspect
    self
  end
end

obj = C.new

DRb.start_service("druby://#{ENV['LOCAL_HOST_ADDRESS']}:8080", obj)
puts "Start server process on #{DRb.uri}"
sleep
