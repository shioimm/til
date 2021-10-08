def fact(x)
  if x == 1
    1
  else
    x * fact(x - 1)
  end
end

p fact(10)
