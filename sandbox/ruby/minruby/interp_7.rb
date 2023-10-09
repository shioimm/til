# RubyでつくるRuby 7

require "minruby"

# pp(minruby_parse("p(1)"))
# # => ["func_call", "p", ["lit", 1]]
#
# pp(minruby_parse("p(1, 2)"))
# # => ["func_call", "p", ["lit", 1], ["lit", 2]]

def evaluate(tree, lenv, genv)
  case tree[0]
  when "lit"
    tree[1]
  when "+"
    evaluate(tree[1], lenv, genv) + evaluate(tree[2], lenv, genv)
  when "-"
    evaluate(tree[1], lenv, genv) - evaluate(tree[2], lenv, genv)
  when "*"
    evaluate(tree[1], lenv, genv) * evaluate(tree[2], lenv, genv)
  when "/"
    evaluate(tree[1], lenv, genv) / evaluate(tree[2], lenv, genv)
  when ">"
    evaluate(tree[1], lenv, genv) > evaluate(tree[2], lenv, genv)
  when "<"
    evaluate(tree[1], lenv, genv) < evaluate(tree[2], lenv, genv)
  when "=="
    evaluate(tree[1], lenv, genv) == evaluate(tree[2], lenv, genv)
  when "func_call"
    args = []
    i = 0
    while tree[i + 2]
      args[i] = evaluate(tree[i + 2], lenv, genv)
      i = i + 1
    end
    mhd = genv[tree[1]]
    if mhd[0] == "builtin"
      minruby_call(mhd[1], args)
    else
      # WIP
    end
  when "stmts"
    i = 1
    last = nil
    while tree[i]
      last = evaluate(tree[i], lenv, genv)
      i += 1
    end
    last
  when "var_assign"
    lenv[tree[1]] = evaluate(tree[2], lenv, genv)
  when "var_ref"
    lenv[tree[1]]
  when "if"
    if evaluate(tree[1], lenv, genv)
      evaluate(tree[2], lenv, genv)
    else
      evaluate(tree[3], lenv, genv)
    end
  when "while"
    while evaluate(tree[1], lenv, genv)
      evaluate(tree[2], lenv, genv)
    end
  end
end

lenv = {}
genv = { "p" => ["builtin", "p"] }
str  = minruby_load
tree = minruby_parse(str)

evaluate(tree, lenv, genv)
