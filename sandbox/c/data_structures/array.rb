# 配列

arr = []
arr[0] = "Blue"
arr[1] = "Yellow"
arr[2] = "Red"

puts arr

puts("----")

# 挿入
arr[3] = arr[2]
arr[2] = "Green"

puts arr

puts("----")

# 削除
arr[2] = arr[3]
arr.delete_at(3)

puts arr
