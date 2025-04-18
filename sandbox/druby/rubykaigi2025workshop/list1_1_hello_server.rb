require "drb"

class Hello
  def greeting
    puts "Hello, World"
  end
end

uri = "druby://localhost:54000"
DRb.start_service(uri, Hello.new)

sleep
