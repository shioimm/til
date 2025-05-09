package main

import "fmt"

func main() {
	var nilMap map[string]int
	fmt.Println(nilMap) // map[]
	fmt.Println(nilMap["abc"]) // 0

	emptyMap := map[string]int{}
	fmt.Println(emptyMap) // map[]
	fmt.Println(emptyMap["abc"]) // 0
	emptyMap["abc"] = 1
	fmt.Println(emptyMap["abc"]) // 1

	maps := map[string]int {
		"abc": 1,
		"def": 2,
	}
	fmt.Println(maps) // map[abc:1 def:2]
	fmt.Println(maps["abc"]) // 1
	maps["abc"] = 2
	fmt.Println(maps["abc"]) // 2

	madeMap := make(map[string]int, 3) // キャパシティ3のmap
	fmt.Println(madeMap) // map[]
	madeMap["abc"] = 1
	fmt.Println(madeMap) // map[abc:1]

	v, ok := madeMap["abc"]
	fmt.Println(v, ok) // 1 true
	v, ok = madeMap["def"]
	fmt.Println(v, ok) // 0 false

	delete(madeMap, "abc")
	fmt.Println(madeMap) // map[]

}
