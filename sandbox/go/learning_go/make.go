package main

import "fmt"

func main() {
	var y = make([]int, 0, 5)
	y = append(y, 1, 2, 3)
	fmt.Println(y, len(y), cap(y)) // [1 2 3] 3 5
}
