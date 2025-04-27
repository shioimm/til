// https://www.kohgakusha.co.jp/books/detail/978-4-7775-2239-2
// $ go mod init functions
// $ go mod edit -replace server/data=../data
// $ go mod tidy
package functions

import (
	"fmt"
	"server/data"
)

func Add(x int, y int) int {
	return x + y
}

func Sub(x int, y int) (int, float64) {
	return x, float64(y)
}

func AddAll(sl []int, x int) {
	for i := 0; i < len(sl); i++ {
		sl[i] += x
	}
}

func AddAndCopy(sl []int, x int) []int {
	cp := []int{}

	for i := 0; i < len(sl); i++ {
		cp = append(cp, sl[i] + x)
	}

	return cp
}

func Describe(member data.Member) string {
	str := fmt.Sprintf(data.Describe(member))
	str += "\n"
	return str
}

func DescribeAll(members []data.Member) string {
	str := ""

	for _, member := range(members) {
		str += Describe(member)
	}

	return str
}
