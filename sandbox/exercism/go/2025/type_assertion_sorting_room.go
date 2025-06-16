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

func DescribeFancyNumberBox(fnb FancyNumberBox) string {
	return fmt.Sprintf(
		"This is a fancy box containing the number %.1f",
		float64(ExtractFancyNumber(fnb)),
	)
}

func DescribeAnything(i interface{}) string {
	if n, ok := i.(int); ok {
		return DescribeNumber(float64(n))
	} else if f, ok := i.(float64); ok {
		return DescribeNumber(f)
	} else if nb, ok := i.(NumberBox); ok {
		return DescribeNumberBox(nb)
	} else if fnb, ok := i.(FancyNumberBox); ok {
		return DescribeFancyNumberBox(fnb)
	} else {
		return "Return to sender"
	}
}
