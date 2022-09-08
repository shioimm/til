require "drb"

class Foo
  def greeting(name)
    "Hello #{name}"
  end

  def sum(x, y)
    x + y
  end

  def with_block
    yield
  end
end

foo = Foo.new
DRb.start_service("druby://localhost:8082", foo)
sleep
