root = RubyVM::AbstractSyntaxTree.parse('Proc.new { _1 }', keep_tokens: true)
pp root.tokens
p eval("#{root.tokens.map { _1[2] }.join}.call('called')")
