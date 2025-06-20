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
	interestRate := InterestRate(balance) / 100
	return balance * float64(interestRate)
}

func AnnualBalanceUpdate(balance float64) float64 {
	interest := Interest(balance)
	return balance + interest
}

func YearsBeforeDesiredBalance(balance, targetBalance float64) int {
	years := 0
	currentBalance := balance

	for targetBalance > currentBalance {
		currentBalance = AnnualBalanceUpdate(currentBalance)
		years++
	}

	return years
}
