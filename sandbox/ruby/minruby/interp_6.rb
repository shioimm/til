# RubyでつくるRuby 6

require 'minruby'

# pp(minruby_parse("
# if 0  == 0
#   p(42)
# else
#   p(43)
# end
# "))
# # => ["if",
#        ["==", ["lit", 0], ["lit", 0]],
#        ["func_call", "p", ["lit", 42]],
#        ["func_call", "p", ["lit", 43]]]

# pp(minruby_parse("
# i = 0
# while i < 10
# p(i)
# i = i + 1
# end
# "))
# # => ["stmts",
#        ["var_assign", "i", ["lit", 0]],
#        ["while",
#          ["<", ["var_ref", "i"], ["lit", 10]],
#          ["stmts",
#            ["func_call", "p", ["var_ref", "i"]],
#            ["var_assign", "i", ["+", ["var_ref", "i"], ["lit", 1]]]]]]

# pp(minruby_parse("
# case 42
# when 0
#   p(0)
# when 1
#   p(1)
# else
#   p(2)
# end
# "))
# # => ["if",
#        ["==", ["lit", 42], ["lit", 0]],
#        ["func_call", "p", ["lit", 0]],
#        ["if",
#          ["==", ["lit", 42], ["lit", 1]],
#          ["func_call", "p", ["lit", 1]],
#          ["func_call", "p", ["lit", 2]]]]

def evaluate(tree, env)
  case tree[0]
  when 'lit'
    tree[1]
  when '+'
    evaluate(tree[1], env) + evaluate(tree[2], env)
  when '-'
    evaluate(tree[1], env) - evaluate(tree[2], env)
  when '*'
    evaluate(tree[1], env) * evaluate(tree[2], env)
  when '/'
    evaluate(tree[1], env) / evaluate(tree[2], env)
  when '>'
    evaluate(tree[1], env) > evaluate(tree[2], env)
  when '<'
    evaluate(tree[1], env) < evaluate(tree[2], env)
  when '=='
    evaluate(tree[1], env) == evaluate(tree[2], env)
  when 'func_call'
    p evaluate(tree[2], env)
  when "stmts"
    i = 1
    last = nil
    while tree[i]
      last = evaluate(tree[i], env)
      i += 1
    end
    last
  when "var_assign"
    env[tree[1]] = evaluate(tree[2], env)
  when "var_ref"
    env[tree[1]]
  when "if"
    if evaluate(tree[1], env)
      evaluate(tree[2], env)
    else
      evaluate(tree[3], env)
    end
  when "while"
    while evaluate(tree[1], env)
      evaluate(tree[2], env)
    end
  end
end

env  = {}
str  = minruby_load
tree = minruby_parse(str)

evaluate(tree, env)
