// https://www.kohgakusha.co.jp/books/detail/978-4-7775-2239-2
// $ go mod init data
package data

import "fmt"

type Member struct {
	Name string
	Point int
	Coeff float64
}

func Effective(member Member) float64 {
	return float64(member.Point) * member.Coeff
}

func Describe(member Member) string {
	return fmt.Sprintf("%s: %d pt, %.2f pt (effective)", member.Name, member.Point, Effective(member))
}

func HighestPointMember(members[] Member) Member {
	temp := members[0]

	for _, member := range members {
		if Effective(member) > Effective(temp) {
			temp = member
		}
	}

	return temp
}

func AddPoint(member **Member, pt int) {
	(**member).Point += pt
}

func NewMember(member Member, name string) Member {
	member.Name = name
	return member
}

func (member Member)AnotherEffective() float64 {
	return float64(member.Point) * member.Coeff
}

func (member Member)AnotherDescribe() string {
	return fmt.Sprintf("%s: %d pt, %.2f pt (effective)", member.Name, member.Point, member.AnotherEffective())
}

func (member *Member)AnotherAddPoint(pt int) {
	member.Point += pt
}

type Coordinate struct {
	Name string
	X int
	Y int
	Record string
}

func CreateCoodinate(name string, x int, y int) Coordinate {
	c := Coordinate{}
	c.Name = name
	c.X = x
	c.Y = y
	c.Record = fmt.Sprintf("%s started at (%d, %d)\n", c.Name, c.Y, c.Y)
	return c
}

func (c Coordinate)Move(x int, y int) Coordinate {
	c.X = x
	c.Y = y
	c.Record += fmt.Sprintf("-> (%d, %d)\n", x, y)
	return c
}

func (c Coordinate)Terminate() Coordinate {
	c.Record += fmt.Sprintf("%s terminated at (%d, %d)\n", c.Name, c.X, c.Y)
	return c
}
