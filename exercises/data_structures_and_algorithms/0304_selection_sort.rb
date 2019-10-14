def selection_sort(arr)
  # 配列を左から探索し、未探索の部分から最も小さい要素を、探索済みの部分の末尾に追加する
  arr.each_with_index do |n, i|
    minimum_index = i

    # arr[i]は現在探索中であり、iより小さい数字はすでに探索済みのため、i + 1以降を探索する
    (arr[i + 1..]).each do |nn|
      # 現在探索中の要素よりも小さい要素をみつけたらminimum_indexを更新
      minimum_index = arr.index(nn) if arr[minimum_index] > nn
    end

    # 現在探索中の要素と、見つかった最も小さい要素を交換
    arr[minimum_index], arr[i] = arr[i], arr[minimum_index]
  end

  arr
end

arr = [5, 6, 4, 2, 1, 3]

p selection_sort(arr)
