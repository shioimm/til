require 'drb'

class Foo
  def greeting
    'Hello'
  end
end

foo = Foo.new
DRb.start_service('druby://localhost:8080', foo)
sleep
