// https://exercism.org/tracks/go/exercises/acronym

package acronym

import (
	"regexp"
	"strings"
)

func Abbreviate(s string) string {
	re := regexp.MustCompile(`(?:^|\s|[_-])(\pL)`)
	matches := re.FindAllStringSubmatch(s, -1)
	output := ""

	for _, match := range matches {
		output += match[1]
	}

	return strings.ToUpper(output)
}
