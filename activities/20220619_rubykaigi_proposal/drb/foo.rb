require 'drb'

class Foo
  def greeting(name)
    "Hello #{name}"
  end

  def add(n)
    1 + n
  end

  def with_block
    yield
  end
end

foo = Foo.new
DRb.start_service('druby://localhost:8082', foo)
sleep
