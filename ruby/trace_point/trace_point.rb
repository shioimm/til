# TracePoint の拡張 from https://techlife.cookpad.com/entry/2018/12/27/093914

def foo
  bar
end

def bar
  nil
end

indent = 0

TracePoint.trace(:call, :return) do |tp|
  indent -= 2 if tp.event == :return
  print ' ' * indent
  p tp
  indent += 2 if tp.event == :call
  # returnは必ずcallの後に呼ばれるので、-=でインデントの位置を元に戻していく
end

foo
