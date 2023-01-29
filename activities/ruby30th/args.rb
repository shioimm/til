def foo(arg = true ? 'ok' : 'ng')
 p arg # => 'ok'
end

def bar(arg: def m; 'This is an arg'; end)
  p arg # => :m
  p self.method(:m).call # => 'This is an arg'
end

foo
bar
