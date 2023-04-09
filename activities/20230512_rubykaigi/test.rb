#test.rb
i = 0

p i++ # => expect 1
p i   # => expect 1

p "---------"

p i++ * 2 # => expect: 4
p i       # => expect: 2

p "---------"

p :ok if i++ && true # => expect: :ok
p i                  # => expect: 3
