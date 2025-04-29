// https://www.kohgakusha.co.jp/books/detail/978-4-7775-2239-2
// $ go mod init server
// $ go mod edit -replace server/functions=./functions
// $ go mod tidy
// $ go mod edit -replace server/data=./data
// $ go mod tidy
// $ go build server.go
package main

import (
	"fmt"
	"net/http"
	"server/functions"
	"server/data"
)

func add(writer http.ResponseWriter, req *http.Request) {
	result := functions.Add(1, 2)
	fmt.Fprintf(writer, "1 + 2 = %d\n", result)
}

func sub(writer http.ResponseWriter, req *http.Request) {
	x, y := functions.Sub(1, 2)
	fmt.Fprintf(writer, "x = %d, y = %.1f\n", x, y)
}

func slices(writer http.ResponseWriter, req *http.Request) {
	sl1 := []int{1, 2, 3}

	fmt.Fprintln(writer, "(AddAll) Before: ")
	fmt.Fprintln(writer, sl1)

	functions.AddAll(sl1, 100)

	fmt.Fprintln(writer, "(AddAll) After: ")
	fmt.Fprintln(writer, sl1)

	sl2 := functions.AddAndCopy(sl1, 1000)
	fmt.Fprintln(writer, "(AddAndCopy)")
	fmt.Fprintln(writer, sl2)
}

func structs(writer http.ResponseWriter, req *http.Request) {
	members := []data.Member {
		data.Member{ "foo", 123, 1.23 },
		data.Member{ "bar", 456, 4.56 },
	}

	fmt.Fprintln(writer, functions.DescribeAll(members))
	fmt.Fprintln(writer, functions.DescribeHighest(members))

	member := &members[0]
	fmt.Fprintln(writer, functions.AddMemberPoint(&member, 12))
	fmt.Fprintln(writer, functions.DescribeAll(members))

	newMember, str := functions.ReferAFriend(members[0], "baz")
	fmt.Fprintln(writer, str)
	fmt.Fprintln(writer, functions.Describe(newMember))
	fmt.Fprintln(writer, functions.DescribeAll(members))

	fmt.Fprintln(writer, functions.AnotherDescribeAll(members))
	fmt.Fprintln(writer, functions.AnotherAddMemberPoint(&members[0], 99))
	fmt.Fprintln(writer, functions.Describe(members[0]))
}

func pointers(writer http.ResponseWriter, req *http.Request) {
	mockmemory := []int{1, 23, 45, 6, 78, 99}
	fmt.Fprintln(writer, functions.DescribeMockStruct(mockmemory, 0))
	fmt.Fprintln(writer, functions.DescribeMockStruct(mockmemory, 3))

	x, y := 1, 2
	result := functions.UpdateOrCopy(x, &y)
	fmt.Fprintf(writer, "x = %d, y = %d, result = %d\n", x, y, result)
}

func methods(writer http.ResponseWriter, req *http.Request) {
	c := data.CreateCoodinate("a", 0, 0)
	c = c.Move(2, 3).Move(4, 5).Move(6, 7).Terminate()
	fmt.Fprintln(writer, c.Record)
}

func main() {
	http.HandleFunc("/add", add)
	http.HandleFunc("/sub", sub)
	http.HandleFunc("/slices", slices)
	http.HandleFunc("/structs", structs)
	http.HandleFunc("/pointers", pointers)
	http.HandleFunc("/methods", methods)

	http.ListenAndServe(":8090", nil)
}
