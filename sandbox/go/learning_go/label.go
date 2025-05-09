package main

import "fmt"

func main() {
	samples := []string{"Bar", "Baz"}

outer:
	for _, sample := range samples {
		for _, c := range sample {
			fmt.Println(c)
			if c == 'a' {
				continue outer
			}
		}
		fmt.Println(sample)
	}

	fmt.Println(samples)
}
