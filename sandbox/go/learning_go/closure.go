package main

import (
	"fmt"
	"sort"
)

type Person struct {
	name string
	age int
}

func makeMult(base int) func(int) int {
	return func(factor int) int {
		return base * factor
	}
}
func main() {
	people := []Person{
		{"Pat", 37},
		{"Tracy", 23},
		{"Fred", 18},
	}

	fmt.Println("initial -- ", people)

	sort.Slice(people, func(base int, val int) bool {
		return people[base].name < people[val].name
	})
	fmt.Println("sorted by name -- ", people)

	sort.Slice(people, func(base int, val int) bool {
		return people[base].age < people[val].age
	})
	fmt.Println("sorted by age -- ", people)

	twoBase := makeMult(2)
	threeBase := makeMult(3)
	for i := 0; i < 5; i++ {
		fmt.Println(i, ": ", twoBase(i), ", ", threeBase(i), "\n")
	}
}
