// https://exercism.org/tracks/go/exercises/bob

package bob

import (
	"regexp"
	"strings"
)

func isAsking(remark string) bool {
	re := regexp.MustCompile(`\?$`)
	return re.MatchString(remark)
}

func isYelling(remark string) bool {
	re := regexp.MustCompile(`[A-Z]+`)
	return re.MatchString(remark) && strings.ToUpper(remark) == remark
}

func isSpeakingNothing(remark string) bool {
	return remark == ""
}

func Hey(remark string) string {
	r := strings.TrimSpace(remark)

	switch {
	case isSpeakingNothing(r): return "Fine. Be that way!"
	case isYelling(r) && isAsking(r): return "Calm down, I know what I'm doing!"
	case isAsking(r): return "Sure."
	case isYelling(r): return "Whoa, chill out!"
	default: return "Whatever."
	}
}
