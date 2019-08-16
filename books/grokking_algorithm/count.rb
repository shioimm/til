def count(arr)
  if arr.empty?
    0
  else
    1 + count(arr - [arr.first])
  end
end

p count([1, 2, 3])
