class Foo
  def method_missing(name, *_args, &_b)
    puts "##{name}"
  end
end

Foo.new.ruby30th
