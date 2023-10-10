def select_sort(arr)
  sorted_arr = []

  loop do
    arr.each do |a|
      if a == arr.min
        sorted_arr << a
        arr.delete(a)
      end
    end

    return sorted_arr if arr.empty?
  end
end

p select_sort(Array(1..10).shuffle)
