MESSAGE = %w[# r u b y 3 0 t h]
i = MESSAGE.length

def foo(i)
  yield foo(i - 1) { print MESSAGE[i] } if i >= -1
end

foo(i) { |f| f; puts "\n" }
