# RubyでつくるRuby 5

require 'minruby'

# 変数代入
# pp(minruby_parse("
# x = 1
# y = 2 * 3
# "))
# # => ["stmts",
# #      ["var_assign", "x", ["lit", 1]],
# #      ["var_assign", "y", ["*", ["lit", 2], ["lit", 3]]]]

# 変数参照
# pp(minruby_parse("
# x = 1
# y = 2 + x
# "))
# => ["stmts",
#      ["var_assign", "x", ["lit", 1]],
#      ["var_assign", "y", ["+", ["lit", 2], ["var_ref", "x"]]]]

# 木をたどる関数
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
  end
end

env  = {} # 環境の初期状態
str  = minruby_load # ソースプログラム
tree = minruby_parse(str) # 抽象構文木

evaluate(tree, env) # 抽象構文木と環境を指定して実行開始
