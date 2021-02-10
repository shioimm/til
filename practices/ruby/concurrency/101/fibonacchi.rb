def solve_fibonacci(max)
  x, y = 0, 1

  (1..max).each_with_object([]) do |_, arr|
    arr << y
    x, y = y, (x + y)
  end
end
