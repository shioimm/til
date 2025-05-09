package main

import "fmt"

func main() {
	type foo struct {
		no int
	}

	type bar struct {
		no int
	}

	x := foo{ 1 }
	y := foo{ 1 }
	// z := bar{ 1 }

	fmt.Println(x == y) // true
	// fmt.Println(x == z) // mismatched types foo and bar
}
