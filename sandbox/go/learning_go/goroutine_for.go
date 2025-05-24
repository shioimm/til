package main

import "fmt"

func main() {
	x := []int{1, 2, 3, 4, 5, 6, 7, 8, 9}
	ch := make(chan int, len(x))

	for _, v := range x {
		go func(val int) {
			ch <- val * 2
		}(v)
	}

	for i := 0; i < len(x); i++ {
		fmt.Print(<-ch, " ")
	}
}
