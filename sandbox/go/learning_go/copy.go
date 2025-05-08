package main

import "fmt"

func main() {
	x := []int{1, 2, 3}
	y := make([]int, 3)
	num := copy(y, x)
	fmt.Println(y, num) // [1 2 3] 3
}
