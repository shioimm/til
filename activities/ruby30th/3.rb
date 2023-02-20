class Foo
  def foo
    puts "#ruby30th"
  end
end

Foo.new.foo

Bar = Class.new do
  define_method(:bar) do
    IO.new(2).puts "#ruby30th"
  end
end

Bar.new.bar
