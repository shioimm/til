p Class.new
p Module.new
p Exception.new
p Errno::ESHUTDOWN.new
p self.method(:__method__)
p self.method(:__method__).unbind
p self.binding
p TracePoint.new(:call) { |tp| tp.event }
