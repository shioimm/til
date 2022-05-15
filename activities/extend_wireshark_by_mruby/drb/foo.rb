require 'drb'

class Foo
  def greeting(name)
    "Hello #{name}"
  end
end

foo = Foo.new
DRb.start_service('druby://localhost:8080', foo)
sleep
