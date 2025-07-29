// https://exercism.org/tracks/go/exercises/luhn

package luhn

import "unicode"

const MinimumLength = 1
const MaximumDigit = 9
const Divizor = 10

func Valid(id string) bool {
	digits := []rune(id)
	sum := 0
	digitIndex := 0

	for i := len(digits) - 1; i >= 0; i-- {
		r := digits[i]

		if !unicode.IsDigit(r) {
			if !unicode.IsSpace(r) { return false }
			continue
		}

		digit := int(r - '0')
		digitIndex++

		if (digitIndex % 2 == 0) {
			digit *= 2
			if digit > MaximumDigit {
				digit -= MaximumDigit
			}
		}

		sum += digit
	}

	return digitIndex > MinimumLength && sum % Divizor == 0
}
