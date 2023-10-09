# RubyでつくるRuby 8

require "minruby"

# pp(minruby_parse("
# def add(x, y)
#   x + y
# end
# "))
# => ["func_def",
#      "add",
#      ["x", "y"],
#      ["+", ["var_ref", "x"], ["var_ref", "y"]]]

# pp(minruby_parse("
# add(1 + 2)
# "))
# => ["func_call",
#      "add",
#      ["+", ["lit", 1], ["lit", 2]]]

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
    # genv: { 関数名 => [関数タイプ, 関数の実装]}
    # tree: ["func_call", 関数名, ["var_ref", 変数名]]
    # mhd:  [関数タイプ, 関数の実装]
    mhd = genv[tree[1]]
    if mhd[0] == "builtin"
      minruby_call(mhd[1], args)
    else
      # params: [仮引数, ...]
      params = mhd[1]
      i = 0
      while params[i]
        lenv[params[i]] = args[i]
        i = i + 1
      end
      # lenv: { 仮引数 => 実引数, ... }
      evaluate(mhd[2], lenv, genv)
    end
  when "func_def"
    # 関数名 => ["user_defined", 仮引数名の配列, 関数本体]
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
