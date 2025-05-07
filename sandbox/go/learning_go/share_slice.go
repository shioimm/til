package main

import "fmt"

func main() {
	x := make([]int, 0, 5)
	x = append(x, 1, 2, 3, 4) // [1 2 3 4]

	y := x[:2]
	z := x[2:]

	fmt.Println(x, cap(x)) // [1 2 3 4] 5
	fmt.Println(y, cap(y)) // [1 2] 5
	fmt.Println(z, cap(z)) // [3 4] 3

	y = append(y, 30, 40, 50)
	x = append(x, 60)
	z = append(z, 70)

	fmt.Println(x, cap(x)) // [1 2 30 40 70] 5
	fmt.Println(y, cap(y)) // [1 2 30 40 70] 5
	fmt.Println(z, cap(z)) // [30 40 70] 3
}
