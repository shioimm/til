package main

import "fmt"

func main() {
	var s string = "Hello, ☀️"
	var b []byte = []byte(s)
	var r []rune = []rune(s)

	fmt.Println(s) // Hello, ☀️
	fmt.Println(b) // [72 101 108 108 111 44 32 226 152 128 239 184 143]
	fmt.Println(r) // [72 101 108 108 111 44 32 9728 65039]

	for i, c := range s {
		fmt.Println(i, c, string(c))
	}
}
