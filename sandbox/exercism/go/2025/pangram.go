// https://exercism.org/tracks/go/exercises/pangram

package pangram

import "unicode"

func IsPangram(input string) bool {
	chars := []rune(input)
	letters := make(map[rune]bool)

	for i := 0; i < 26; i++ {
		letters[rune('a' + i)] = false
	}

	for _, c := range chars {
		c = unicode.ToLower(c)
		if !letters[c] {
			letters[c] = true
		}
	}

	for _, seen := range letters {
		if !seen {
			return false
		}
	}

	return true
}
