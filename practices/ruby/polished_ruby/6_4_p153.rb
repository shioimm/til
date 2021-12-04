def meth(arg)
  p arg
end

meth *1

meth = 2

meth *1

# $ ruby -wc 6_4_p153.rb
# 6_4_p153.rb:5: warning: `*' interpreted as argument prefix
# 6_4_p153.rb:9: warning: `*' after local variable or literal is interpreted as binary operator
# 6_4_p153.rb:9: warning: even though it seems like argument prefix
# 6_4_p153.rb:9: warning: possibly useless use of * in void context
# Syntax OK
