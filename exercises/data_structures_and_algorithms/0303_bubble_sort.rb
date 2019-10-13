# 隣接している要素同士を比較して、順番が逆になっている要素がなくなるまで処理を続ける
def bubble_sort(arr)
  # 順番が逆になっている要素が残っていることを示す変数reverse
  reversed      = true
  maximum_index = arr.size - 1

  while reversed do
    reversed = false

    # 配列の右端から処理を始める
    maximum_index.downto(1) do |i|
      # 順番が逆になっている場合は入れ替える
      if arr[i] < arr[i - 1]
        arr[i], arr[i - 1] = arr[i - 1], arr[i]
        reversed = true
      end
    end
  end

  arr
end

arr = [5, 4, 3, 2, 1]

p bubble_sort(arr)
