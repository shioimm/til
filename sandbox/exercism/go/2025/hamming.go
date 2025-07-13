// https://exercism.org/tracks/go/exercises/hamming

package hamming

import "errors"

func Distance(a, b string) (int, error) {
	if len(a) != len(b) {
		return 0, errors.New("invalid size")
	}

	count := 0

	for i := range(a) {
		if a[i] != b[i] { count ++ }
	}

	return count, nil
}
