package main

import "fmt"

func main() {
	ch1 := make(chan int)
	ch2 := make(chan int)

	go func() {
		a := 1
		ch1 <- a
		b := <-ch2
		fmt.Print(a, ", ", b, "\n")
	}()

	c := 2
	var d int

	select {
	case ch2 <- c:
	case d = <- ch1:
	}
	fmt.Print(c, ", ", d, "\n")
}
