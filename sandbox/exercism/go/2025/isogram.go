// https://exercism.org/tracks/go/exercises/isogram

package isogram

import (
	"regexp"
	"strings"
)

func IsIsogram(word string) bool {
	lower := strings.ToLower(word)
	re := regexp.MustCompile(`\w`)
	letters := re.FindAllString(lower, -1)
	counts := make(map[string]int)

	for _, l := range letters {
		counts[l]++
	}

	for _, count := range counts {
		if count > 1 { return false }
	}

	return true
}
