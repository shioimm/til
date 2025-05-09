package main

import "fmt"

func addTo(base int, vals ...int) []int {
	out := make([]int, 0, len(vals))

	for _, v := range vals {
		out = append(out, base + v)
	}

	return out
}

func main() {
	fmt.Println(addTo(1))
	fmt.Println(addTo(1, 2))
	fmt.Println(addTo(1, 2, 3))

	x := []int{3, 4}
	fmt.Println(addTo(10, x...))

	fmt.Println(addTo(10, []int{5, 6}...))
}
