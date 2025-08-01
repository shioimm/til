package triangle

type Kind int

const (
	NaT Kind = 0
	Equ Kind = 1
	Iso Kind = 2
	Sca Kind = 3
)

func uniq(input []float64) []float64 {
	seen := make(map[float64]bool)
	output := []float64{}

	for _, val := range input {
		if !seen[val] {
			seen[val] = true
			output = append(output, val)
		}
	}

	return output
}

func hasInvalidValue(input []float64) bool {
	for _, val := range input {
		if 0 >= val {
			return true
		}
	}
	return false
}

func hasInvalidSide(input []float64) bool {
	maximum := 0.0
	idx := 0

	for i, side := range input {
		if side > maximum {
			maximum = side
			idx = i
		}
	}

	rests := append(input[:idx], input[idx + 1:]...)
	sum := 0.0

	for _, r := range rests {
		sum += r
	}

	return maximum > sum
}

func KindFromSides(a, b, c float64) Kind {
	var k Kind
	sides := []float64{a, b, c}
	uniqSides := uniq(sides)
	k = Kind(len(uniqSides))

	if hasInvalidValue(sides) || ((k == Iso || k == Sca) && hasInvalidSide(sides)){
		return NaT
	}

	return k
}
