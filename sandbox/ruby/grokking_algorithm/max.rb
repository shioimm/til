def max(arr)
  if arr.empty?
    0
  else
    num = max(arr - [arr.first])
    arr.first > num ? arr.first : num
  end
end

p max([1, 2, 3].shuffle)
