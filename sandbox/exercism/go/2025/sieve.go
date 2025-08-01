// https://exercism.org/tracks/go/exercises/sieve

package sieve

func none(primes []int, n int) bool {
	for _, p := range primes {
		if n % p == 0  {
			return false
		}
	}
	return true
}

func Sieve(limit int) []int {
	var result []int

	if 2 > limit {
		return result
	}

	for i:= 2; limit >= i; i++ {
		if none(result, i) {
			result = append(result, i)
		}
	}

	return result
}
