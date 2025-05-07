package main

import "fmt"

func main() {
	var x = 1
	x = "foo" // cannot use "foo" (untyped string constant) as int value in assignment

	fmt.Println(x)
}
