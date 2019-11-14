# Q19 from プログラマ脳を鍛える数学パズル シンプルで高速なコードが書けるようになる70問

require 'prime'

primes = Prime.take(6)
min = primes.last * primes.last
min_friend = []

primes.permutation do |prime|
  friends = prime.each_cons(2).map { |x, y| x * y }
  friends += [prime.first, prime.last].map { |x| x * x }

  if min > friends.max
    min = friends.max
    min_friend = friends
  end
end

p min

# Array#permutation
# https://docs.ruby-lang.org/ja/2.6.0/method/Array/i/permutation.html
