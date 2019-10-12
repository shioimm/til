def insertion_sort(unsorted)
  sorted = []

  unsorted.each_with_index do |n, i|
    # 最初の要素をsortedに格納する
    next sorted << n if sorted.empty?

    previous_index = i - 1

    # sorted[previous_index] > n => 一つ前にsortedに格納された要素が自分よりも大きい場合
    # previous_index >= 0        => 探索中のインデックスが0以上の場合
    while sorted[previous_index] > n && previous_index >= 0
      # 自分よりも大きい要素を空いているインデックスに格納する
      sorted[previous_index + 1] = sorted[previous_index]
      # 探索中のインデックスをデクリメントする
      previous_index -= 1
    end

    # 空いた場所に自分を格納する
    sorted[previous_index + 1] = n
  end

  sorted
end

arr1 = [8, 3, 1, 5, 2, 1]
arr2 = [5, 2, 4, 6, 1, 3]

p insertion_sort(arr1)
p insertion_sort(arr2)
