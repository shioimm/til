// https://exercism.org/tracks/go/exercises/sorting-room

package sorting

import (
	"fmt"
	"strconv"
)

func DescribeNumber(f float64) string {
	return fmt.Sprintf(
		"This is the number %s",
		strconv.FormatFloat(f, 'f', 1, 64),
	)
}

type NumberBox interface {
	Number() int
}

func DescribeNumberBox(nb NumberBox) string {
	return fmt.Sprintf(
		"This is a box containing the number %s",
		strconv.FormatFloat(float64(nb.Number()), 'f', 1, 64),
	)
}

type FancyNumber struct {
	n string
}

func (i FancyNumber) Value() string {
	return i.n
}

type FancyNumberBox interface {
	Value() string
}

func ExtractFancyNumber(fnb FancyNumberBox) int {
	fancy, ok := fnb.(FancyNumber)

	if (!ok) { return 0 }

	value, _ := strconv.Atoi(fancy.Value())

	return value
}
