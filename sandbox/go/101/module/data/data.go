// $ go mod init data
package data

import "fmt"

type Member struct {
	Name string
	Point int
	Coeff float64
}

func Effective(m Member) float64 {
	return float64(m.Point) * m.Coeff
}

func Describe(m Member) string {
	return fmt.Sprintf("%s: %d pt, %.2f pt (effective)", m.Name, m.Point, Effective(m))
}
