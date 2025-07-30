// https://exercism.org/tracks/go/exercises/reverse-string

package reverse

func Reverse(input string) string {
	chars := []rune(input)
	var output []rune

	for i := len(chars) - 1 ; i >= 0; i-- {
		output = append(output, chars[i])
	}

	return string(output)
}
