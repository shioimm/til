def linear_search(arr, key)
  index = 0
  maximum_index = arr.size - 1

  while index != maximum_index
    return true if arr[index] == key
    index += 1
  end
end

arr1 = [1, 2, 3, 4, 5]
arr2 = [0, 3, 4, 1]

common = arr2.each_with_object([]) { |n, arr| arr << n if linear_search(arr1, n) }
p common.size
