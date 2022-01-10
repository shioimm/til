# RubyでつくるRuby 5

require 'minruby'

# pp(minruby_parse("
#  1 + 2
#  6 * 7
# 40 + 2
# "))
# # => ["stmts",
#        ["+", ["lit", 1], ["lit", 2]],
#        ["*", ["lit", 6], ["lit", 7]],
#        ["+", ["lit", 40], ["lit", 2]]]

def evaluate(tree)
  case tree[0]
  when 'lit'
    tree[1]
  when '+'
    evaluate(tree[1]) + evaluate(tree[2])
  when '-'
    evaluate(tree[1]) - evaluate(tree[2])
  when '*'
    evaluate(tree[1]) * evaluate(tree[2])
  when '/'
    evaluate(tree[1]) / evaluate(tree[2])
  when 'func_call'
    p evaluate(tree[2])
  when "stmts"
    i = 1
    last = nil
    while tree[i] != nil
      last = evaluate(tree[i])
      i += 1
    end
    last
  end
end

str    = minruby_load
tree   = minruby_parse(str)
answer = evaluate(tree)
