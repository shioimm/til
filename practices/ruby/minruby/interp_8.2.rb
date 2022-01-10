# RubyでつくるRuby 8

require "minruby"

# pp(minruby_parse("
# def foo()
#   x = 0
#   p(x)
# end
# x = 1
# foo()
# p(x)
# "))
# => ["stmts",
#     ["func_def",
#      "foo",
#      [],
#      ["stmts", ["var_assign", "x", ["lit", 0]], ["func_call", "p", ["var_ref", "x"]]]],
#     ["var_assign", "x", ["lit", 1]],
#     ["func_call", "foo"],
#     ["func_call", "p", ["var_ref", "x"]]]

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
    while tree[i + 2] # tree[i + 2]: ノードの種類 (e.g. func_call, lit...)
      args[i] = evaluate(tree[i + 2], lenv, genv)
      i = i + 1
    end
    # genv: { 関数名 => [関数タイプ, 関数の実装]}
    # tree: ["func_call", 関数名, ["var_ref", 変数名]]
    mhd = genv[tree[1]]
    if mhd[0] == "builtin" # mhd:  ["builtin", 関数名]
      minruby_call(mhd[1], args)
    else # mhd: ["user_defined", [仮引数名の配列], [関数名, ["var_ref", 仮引数名], ...]]
      new_lenv = {}
      params = mhd[1]
      i = 0
      while params[i]
        new_lenv[params[i]] = args[i]
        i = i + 1
      end
      # new_lenv: { 仮引数 => 実引数, ... }
      evaluate(mhd[2], new_lenv, genv)
    end
  when "func_def"
    # { 関数名 =>  ["user_defined", [仮引数名の配列], [関数名, ["var_ref", 仮引数名], ...]] }
    genv[tree[1]] = ["user_defined", tree[2], tree[3]]
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
