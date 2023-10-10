def sum(arr)
  if arr.empty?
    0
  else
    arr.first + sum(arr - [arr.first])
  end
end

p sum([1, 2, 3])
