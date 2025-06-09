// https://exercism.org/tracks/go/exercises/logs-logs-logs

package logs

func Application(log string) string {
	for _, char := range log {
		if char == '❗' { return "recommendation" }
		if char == '🔍' { return "search" }
		if char == '☀' { return "weather" }
	}
	return "default"
}

func Replace(log string, oldRune, newRune rune) string {
	runes := []rune(log)

	for i, char := range runes {
		if char == oldRune { runes[i] = newRune }
	}

	return string(runes)
}
