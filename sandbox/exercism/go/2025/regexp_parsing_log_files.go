// https://exercism.org/tracks/go/exercises/parsing-log-files

package parsinglogfiles

import "regexp"

func IsValidLine(text string) bool {
	re := regexp.MustCompile(`^\[(TRC|DBG|INF|WRN|ERR|FTL)\]`)
	return re.MatchString(text)
}

func SplitLogLine(text string) []string {
	re := regexp.MustCompile(`\<[-=~*]*\>`)
	return re.Split(text, -1)
}

func CountQuotedPasswords(lines []string) int {
	count := 0
	re := regexp.MustCompile(`".*(?i)password.*"`)

	for _, l := range lines {
		if re.MatchString(l) { count++ }
	}

	return count
}

func RemoveEndOfLineText(text string) string {
	re := regexp.MustCompile(`end-of-line\w*`)
	return re.ReplaceAllString(text, "")
}

func RemoveEndOfLineText(text string) string {
	re := regexp.MustCompile(`end-of-line\w*`)
	return re.ReplaceAllString(text, "")
}

func TagWithUserName(lines []string) []string {
	user := regexp.MustCompile(`User +(\S+)`)

	for i, line := range lines {
		if matched := user.FindStringSubmatch(line); matched != nil {
			lines[i] = "[USR] " + matched[1] + " " + line
		}
	}

	return lines
}
