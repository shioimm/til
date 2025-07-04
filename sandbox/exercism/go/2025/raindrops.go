// https://exercism.org/tracks/go/exercises/raindrops

package raindrops

import("strconv")

func Convert(number int) string {
	sound := ""

	if number % 3 == 0 { sound += "Pling" }
	if number % 5 == 0 { sound += "Plang" }
	if number % 7 == 0 { sound += "Plong" }

	if len(sound) > 0 { return sound }

	return strconv.Itoa(number)
}
