// https://www.kohgakusha.co.jp/books/detail/978-4-7775-2239-2
// $ go mod init data
package data

import (
	"fmt"
	"math"
)

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

type Half float64
type Full int

type Fraction interface {
	Value() string
}

func (h Half)Value() string {
	return fmt.Sprintf("%.1f", float64(h))
}

func (f Full)Value() string {
	return fmt.Sprintf("%d", int(f))
}

type Char struct {
	Value string
}

type Digit struct {
	Value int
}

type Counter interface {
	Count() string
}

func (counter Char)Count() string {
	value := counter.Value
	str := fmt.Sprintf("%s: ", value)
	str += fmt.Sprintf("%d characters\n", len([]rune(value)))
	return str
}

func (counter Digit)Count() string {
	value := counter.Value
	value_s := fmt.Sprintf("%d", value)
	str := fmt.Sprintf("%d: ", value)
	str += fmt.Sprintf("%d characters\n", len([]rune(value_s)))
	return str
}

type MockReader interface {
	Read(content string)
	Write() string
}

type TextReader struct {
	Memory string
}

type NumberReader struct {
	Memory []int
}

func (reader *TextReader)Read(content string) {
	reader.Memory += content
	reader.Memory += "\n"
}

func (reader *NumberReader)Read(content string) {
	digits := "0123456789"

	for _, v := range content {
		for i, c := range digits {
			if v == c {
				reader.Memory = append(reader.Memory, i)
			}
		}
	}
}

func (reader TextReader)Write() string {
	str := reader.Memory
	return str
}

func (reader NumberReader)Write() string {
	str := ""
	for _, number := range reader.Memory {
		str += fmt.Sprintf("%d ", number)
	}
	str += "\n"
	return str
}

func (reader NumberReader)ReaderToPow() int {
	sum := 0
	memory := reader.Memory
	lm := len(memory)

	for i := 0; i < lm; i++ {
		mag := math.Pow10(lm -i)
		sum += memory[i] * int(mag)
	}

	return sum / 10
}
