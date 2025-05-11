package main

import "fmt"

func add(base int, val int) (result int) {
	result = base + val
	return result
}

func add2(base int, val int) (result int) {
	result = base + val
	return
}

func main() {
	fmt.Println(add(1, 2))
	fmt.Println(add2(1, 2))
}
