class Foo
  def foo
    puts "#ruby30th"
  end
end

Foo.new.foo

Bar = Class.new do
  define_method(:bar) do
    stdout = IO.new(2)
    stdout.send(:write, "#ruby30th\n")
  end
end

Bar.new.bar
