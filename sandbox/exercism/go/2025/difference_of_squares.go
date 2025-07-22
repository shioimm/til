// https://exercism.org/tracks/go/exercises/difference-of-squares

package diffsquares

import "math"

func SquareOfSum(n int) int {
	sum := 0

	for i := 1; i <= n; i++ {
		sum += i
	}

	return int(math.Pow(float64(sum), 2.0))
}

func SumOfSquares(n int) int {
	result := 0.0

	for i := 1; i <= n; i++ {
		result += math.Pow(float64(i), 2.0)
	}

	return int(result)
}

func Difference(n int) int {
	return SquareOfSum(n) - SumOfSquares(n)
}
