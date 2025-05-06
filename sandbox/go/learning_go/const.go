package main

import "fmt"

const x int64 = 10

const (
	idKey = "id"
	nameKey = "name"
)

const z = 20 * 10

func main() {
	const y = "hello"

	fmt.Println(x)
	fmt.Println(y)

	// 以下はneither addressable nor a map index expression
	// x = x + 1
	// y = "bye"

	// fmt.Println(x)
	// fmt.Println(y)
}
