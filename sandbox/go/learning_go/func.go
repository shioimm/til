package main

import (
	"fmt"
	"strconv"
)

type opFuncType func(int, int) int

func add(base int, val int) int { return base + val }
func sub(base int, val int) int { return base - val }
func mul(base int, val int) int { return base * val }
func div(base int, val int) int { return base / val }

func main() {
	var opMap = map[string]opFuncType {
		"+": add,
		"-": sub,
		"*": mul,
		"/": div,
	}

	exps := [][]string{
		[]string{"1", "+", "2"},
		[]string{"1", "-", "2"},
		[]string{"2", "*", "2"},
		[]string{"2", "/", "2"},
		[]string{"2", "%", "3"},
		[]string{"two", "+", "three"},
		[]string{"2", "+", "three"},
		[]string{"5"},
	}

	for _, exp := range exps {
		if len(exp) != 3 {
			fmt.Println(exp, "-- invalid\n")
			continue
		}

		p1, err := strconv.Atoi(exp[0])
		if err != nil {
			fmt.Println(exp, "-- ", err, "\n")
			continue
		}

		op := exp[1]
		opFunc, ok := opMap[op]
		if !ok {
			fmt.Println(exp, "-- invalid", op, "\n")
			continue
		}

		p2, err := strconv.Atoi(exp[2])
		if err != nil {
			fmt.Println(exp, "-- ", err, "\n")
			continue
		}

		result := opFunc(p1, p2)
		fmt.Println(result)
	}
}
