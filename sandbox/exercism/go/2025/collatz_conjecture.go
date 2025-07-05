// https://exercism.org/tracks/go/exercises/collatz-conjecture

package collatzconjecture

import "errors"

func CollatzConjecture(n int) (int, error) {
	if 0 >= n { return 0, errors.New("invalid number") }

	step := 0

	for {
		if n == 1 {
			return step, nil
		} else if n % 2 == 0 {
			n = n / 2
		} else {
			n = (n * 3 + 1)
		}

		step++
	}
}
