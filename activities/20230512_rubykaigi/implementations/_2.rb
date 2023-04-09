class Integer
  def __plusplus__(name, b)
    p b.receiver
    b.local_variable_set(name, self.succ)
  end
end

class Foo
  def foo
    i = 0
    p i.__plusplus__('i', binding)
    p i
  end
end

Foo.new.foo
