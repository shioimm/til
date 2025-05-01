// https://www.kohgakusha.co.jp/books/detail/978-4-7775-2239-2
// $ go mod init functions
// $ go mod edit -replace server/data=../data
// $ go mod tidy
package functions

import (
	"fmt"
	"server/data"
	"time"
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

func DescribeFraction(fractions []data.Fraction) string {
	str := ""

	for _, fraction := range fractions {
		str += fmt.Sprintf("%s, ", fraction.Value())
	}

	str += "\n"
	return str
}

func CountAll(counters []data.Counter) string {
	str := ""

	for _, counter := range counters {
		str += counter.Count()
	}

	str += "\n"
	return str
}

func NumReaderToPow(reader data.NumberReader) string {
	str := fmt.Sprintf("%d", reader.ReaderToPow())
	str += "\n"
	return str
}

func TenTimes(num int) string {
	if num < 10 {
		for num < 10 {
			num++
		}
	} else if num > 10 {
		for num > 10 {
			num--
		}
	}

	return fmt.Sprintf("%d", num)
}

func Endless(limit int) string {
	i := 0

	for {
		i++
		if i > limit {
			return fmt.Sprintf("Stopped at %d\n", i)
		}
	}
}

func FizzBuzz(limit int) string {
	i := 1
	str := ""
	for limit >= i {
		switch {
			case i % 15 == 0:
				str += "FizzBuzz\n"
			case i % 5 == 0:
				str += "Buzz\n"
			case i % 3 == 0:
				str += "Fizz\n"
			default:
				str += fmt.Sprintf("%d\n", i)
		}
		i++
	}
	return str
}

func RemoveByIndex[T any](sl []T, idx int) []T {
	rest := []T{}

	for i, value := range sl {
		if i != idx {
			rest = append(rest, value)
		}
	}

	return rest
}

func Record(s string, times int, interval int) string {
	time.Sleep(time.Duration(interval) * time.Millisecond)
	return fmt.Sprintf("%s_%d", s, times)
}

func InChannel(s string, times int, interval int, ch chan string) {
	ch<-Record(s, times, interval)
}
