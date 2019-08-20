# TracePoint の拡張 from https://techlife.cookpad.com/entry/2018/12/27/093914

def foo
  bar
end

def bar
  nil
end

indent = 0

TracePoint.new(:call) do |tp|
  puts "#{' ' * indent} -> #{tp.method_id}@#{tp.path}:#{tp.lineno}"
  indent += 2
end.enable

TracePoint.new(:return) do |tp|
  indent -= 2
  puts "#{' ' * indent} <- #{tp.method_id}@#{tp.path}:#{tp.lineno}"
end.enable

foo
