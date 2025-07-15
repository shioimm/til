// https://exercism.org/tracks/go/exercises/leap

package leap

func IsLeapYear(year int) bool {
	return (year % 400 == 0) || (year % 100 != 0 && year % 4 == 0)
}
