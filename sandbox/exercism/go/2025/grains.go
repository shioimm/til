// https://exercism.org/tracks/go/exercises/grains

package grains

import (
	"math"
	"errors"
)

func Square(number int) (uint64, error) {
	if number > 64 || 0 >= number {
		return 0, errors.New("Invalid number")
	}

	return uint64(math.Pow(2.0, float64(number - 1))), nil
}

func Total() uint64 {
	return ^uint64(0)
}
