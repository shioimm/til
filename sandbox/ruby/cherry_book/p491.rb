# プロを目指す人のためのRuby入門［改訂2版］P491

require 'debug'

def fizz_buzz(n)
  binding.break
  if    n % 15 == 0 then 'Fizz Buzz'
  elsif n %  5 == 0 then 'Buzz'
  elsif n %  3 == 0 then 'Fizz'
  else  n
  end
end

p fizz_buzz(15)
