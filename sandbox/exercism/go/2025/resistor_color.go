// https://exercism.org/tracks/go/exercises/resistor-color

package resistorcolor

func Colors() []string {
	return []string{"black", "brown", "red", "orange", "yellow", "green", "blue", "violet", "grey", "white"}
}

func ColorCode(color string) int {
	var code int

	for i, c := range Colors() {
		if c == color {
			code = i
			break
		}
	}

	return code
}
