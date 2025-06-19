// https://exercism.org/tracks/go/exercises/interest-is-interesting

package interest

func InterestRate(balance float64) float32 {
	switch {
	case balance < 0: return 3.213
	case balance >= 0 && balance < 1000: return 0.5
	case balance >= 1000 && balance < 5000: return 1.621
	case balance >= 5000: return 2.475
	default: return 0
	}
}

func Interest(balance float64) float64 {
	multiplier := InterestRate(balance) / 100
	return balance * float64(multiplier)
}
