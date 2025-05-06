package main

import "fmt"

func main() {
	var x = []int{1, 2: 3} // インデックス2に3を代入 (インデックス1は0埋め)
	fmt.Println(x) // [1 0 3]
}
