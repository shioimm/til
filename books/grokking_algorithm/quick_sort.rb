def quick_sort(arr)
  if arr.length < 2
    arr
  else
    pivot = arr.shift
    smaller = arr.select { |a| a <= pivot }
    bigger = arr.select { |a| a > pivot }
    quick_sort(smaller) + [pivot] + quick_sort(bigger)
  end
end

p quick_sort(Array(1..10).shuffle)
