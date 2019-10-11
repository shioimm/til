def maximum_profit(arr)
  min, max, profit = arr.first, 0, 0

  arr.each do |n|
    max    = max - min < n ? n : max
    profit = max - min
    min    = min > n ? n : min
  end.then { profit }
end

arr1 = [6, 5, 3, 1, 3, 4, 3]
arr2 = [3, 4, 3, 2]

p maximum_profit(arr1)
p maximum_profit(arr2)
