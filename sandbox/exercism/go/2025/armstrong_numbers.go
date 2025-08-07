// https://exercism.org/tracks/go/exercises/armstrong-numbers

package armstrong

import (
	"math"
	"strconv"
)

func IsNumber(n int) bool {
	digits := strconv.Itoa(n)
	power := float64(len(digits))
	sum := 0.0

	for _, d := range digits {
		sum += math.Pow(float64(d - '0'), power)
	}

	return int(math.Round(sum)) == n
}
