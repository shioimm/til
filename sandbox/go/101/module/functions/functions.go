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

func DescribeHighest(members []data.Member) string {
	str := ""

	member := data.HighestPointMember(members)

	str += fmt.Sprintf("Highest: %s", member.Name)

	return str
}

func AddMemberPoint(member **data.Member, pt int) string {
	data.AddPoint(member, pt)
	str := ""
	str += fmt.Sprintf("Add %d pt for %s\n", pt, (**member).Name)
	return str
}

func ReferAFriend(member data.Member, name string) (data.Member, string) {
	newMember := data.NewMember(member, name)
	str := ""
	str += fmt.Sprintf("Join %s refered from %s\n", name, member.Name)
	return newMember, str
}

func DescribeMockStruct(mockmemory []int, mockaddress int) string {
	str := fmt.Sprintf("no.%d: ", mockmemory[mockaddress])
	str += fmt.Sprintf("%d pt ", mockmemory[mockaddress + 1])
	str += fmt.Sprintf("(Rank %d)\n", mockmemory[mockaddress + 2])
	return str
}

func UpdateOrCopy(x int, y *int) int {
	x += 1
	*y += 1
	return x
}

func AnotherDescribeAll(members []data.Member) string {
	str := ""

	for _, member := range(members) {
		str += member.AnotherDescribe()
		str += "\n"
	}

	return str
}

func AnotherAddMemberPoint(member *data.Member, pt int) string {
	member.AnotherAddPoint(pt)
	str := ""
	str += fmt.Sprintf("Add %d pt for %s\n", pt, member.Name)
	return str
}
