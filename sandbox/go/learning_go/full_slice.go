package main

import "fmt"

func main() {
	x := make([]int, 0, 5)
	x = append(x, 1, 2, 3, 4) // [1 2 3 4]

	y := x[2:2]
	z := x[2:4:4]

	fmt.Println(x, cap(x)) // [1 2 3 4] 5
	fmt.Println(y, cap(y)) // [] 3
	fmt.Println(z, cap(z)) // [3 4] 2

	y = append(y, 30, 40, 50)
	x = append(x, 60)
	z = append(z, 70)

	fmt.Println(x, cap(x)) // [1 2 30 40 60] 5
	fmt.Println(y, cap(y)) // [30 40 60] 3
	fmt.Println(z, cap(z)) // [30 40 70] 4
}
