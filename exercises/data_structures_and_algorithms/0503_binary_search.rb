def binary_search(arr, key)
  left, right = 0, arr.size

  while left < right
    mid = (left + right) / 2

    if arr[mid].eql? key
      return mid
    elsif arr[mid] > key
      right = mid
    elsif arr[mid] < key
      left = mid
    end
  end

  return false
end

arr1 = [1, 2, 3, 4, 5]
arr2 = [0, 3, 4, 1]

common = arr2.each_with_object([]) { |n, arr| arr << n if binary_search(arr1, n) }
p common
p common.size
