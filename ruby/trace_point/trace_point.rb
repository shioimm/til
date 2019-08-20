# TracePoint の拡張 from https://techlife.cookpad.com/entry/2018/12/27/093914

def foo
  bar
end

def bar
  nil
end

TracePoint.trace(:call, :return) { |tp| p tp }

foo
