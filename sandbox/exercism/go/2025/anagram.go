// https://exercism.org/tracks/go/exercises/anagram

package anagram

import (
	"sort"
	"strings"
)

func sortedString(input string) string {
	runes := []rune(strings.ToLower(input))

	sort.Slice(runes, func(x, y int) bool {
		return runes[x] < runes[y]
	})

	return string(runes)
}

func Detect(subject string, candidates []string) []string {
	result := []string{}
	sortedSubject := sortedString(subject)

	for _, candidate := range candidates {
		if (!strings.EqualFold(subject, candidate)) && (strings.EqualFold(sortedSubject, sortedString(candidate))) {
			result = append(result, candidate)
		}
	}

	return result
}
