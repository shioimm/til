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

	fractions := []data.Fraction{
		data.Half(1.5),
		data.Full(2),
		data.Half(2.5),
		data.Full(3),
		data.Half(3.5),
	}
	fmt.Fprintln(writer, functions.DescribeFraction(fractions))

	counters := []data.Counter {
		data.Char{"12345"},
		data.Char{"一二三四五"},
		data.Digit{12345},
	}
	fmt.Fprintln(writer, functions.CountAll(counters))

	var reader data.MockReader
	reader = &data.TextReader{}
	reader.Read("12345")
	reader.Read("一二三四五")
	fmt.Fprintln(writer, reader.Write())

	reader = &data.NumberReader{}
	reader.Read("12345")
	reader.Read("一二三四五")
	fmt.Fprintln(writer, reader.Write())

	num_reader := reader.(*data.NumberReader)
	fmt.Fprintln(writer, functions.NumReaderToPow(*num_reader))
}

func flows(writer http.ResponseWriter, req *http.Request) {
	fmt.Fprintln(writer, functions.TenTimes(6))
	fmt.Fprintln(writer, functions.TenTimes(13))
	fmt.Fprintln(writer, functions.TenTimes(10))

	fmt.Fprintln(writer, functions.Endless(10))

	fmt.Fprintln(writer, functions.FizzBuzz(30))
}

func generics(writer http.ResponseWriter, req *http.Request) {
	sl_int := []int{ 1, 2, 3, 4, 5 }
	sl_str := []string{ "一", "二", "三", "四", "五" }

	fmt.Fprintln(writer, sl_int)
	fmt.Fprintln(writer, sl_str)

	new_sl_int := functions.RemoveByIndex(sl_int, 0)
	fmt.Fprintln(writer, new_sl_int)

	new_sl_str := functions.RemoveByIndex(sl_str, 2)
	fmt.Fprintln(writer, new_sl_str)
}

func goroutine(writer http.ResponseWriter, req *http.Request) {
	go func() {
		for i := 0; i < 3; i++ {
			fmt.Fprintln(writer, functions.Record("Hello", i, 100))
		}
	}()

	for i := 0; i < 3; i++ {
		fmt.Fprintln(writer, functions.Record("World", i, 100))
	}
}

func channel1(writer http.ResponseWriter, req *http.Request) {
	ch := make(chan string)

	go functions.InChannel("a", 0, 200, ch)
	go functions.InChannel("b", 0, 100, ch)

	x1 := <-ch
	x2 := <-ch

	fmt.Fprintln(writer, x1)
	fmt.Fprintln(writer, x2)
}

func channel2(writer http.ResponseWriter, req *http.Request) {
	ch := make(chan string, 4)

	go func() {
		for i := 0; i < 3; i++ {
			functions.InChannel("hello", i, 200, ch)
		}
		ch <- "done"
	}()

	for i := 0; i < 3; i++ {
		fmt.Fprintf(writer, "hello_%d\n", i)
	}

	for i := 0; i < 4; i++ {
		x := <-ch
		fmt.Fprintln(writer, x)
	}
}

func main() {
	http.HandleFunc("/add", add)
	http.HandleFunc("/sub", sub)
	http.HandleFunc("/slices", slices)
	http.HandleFunc("/structs", structs)
	http.HandleFunc("/pointers", pointers)
	http.HandleFunc("/methods", methods)
	http.HandleFunc("/flows", flows)
	http.HandleFunc("/generics", generics)
	http.HandleFunc("/goroutine", goroutine)
	http.HandleFunc("/channel1", channel1)
	http.HandleFunc("/channel2", channel2)

	http.ListenAndServe(":8090", nil)
}
