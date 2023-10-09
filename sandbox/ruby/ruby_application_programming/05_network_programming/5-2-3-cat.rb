# 引用: Rubyアプリケーションプログラミング P201

STDOUT.sync = true

while c = STDIN.gets
  STDOUT.putc(c)
end
