// https://www.kohgakusha.co.jp/books/detail/978-4-7775-2239-2

package main

import (
	"fmt"
	"net/http"
	"math"
)

func hello(writer http.ResponseWriter, req *http.Request) {
	fmt.Fprintln(writer, "hello")
}

func algebra(writer http.ResponseWriter, req *http.Request) {
	a := 1
	b := 2
	result := "%d + %d = %d\n"
	fmt.Fprintf(writer, result, a, b, a + b)

	c := 15.0
	d := float64(a + b + 4)
	result = "%.1f / %.1f = %.3f\n"
	fmt.Fprintf(writer, result, c, d, c / d)
}


func mathF(writer http.ResponseWriter, req *http.Request) {
	pow28 := int(math.Pow(2, 8))
	result := "%d ** %d = %d\n"
	fmt.Fprintf(writer, result, 2, 8, pow28)

	rad30 := 30.0 * math.Pi / 180.0
	result = "sin %.1f = %.3f\n"
	fmt.Fprintf(writer, result, 30.0, rad30)
}

func array(writer http.ResponseWriter, req *http.Request) {
	ar1 := [5]int{1, 2, 3, 4, 5}
	fmt.Fprintln(writer, ar1)

	ar2 := [5]int{1, 2, 3}
	fmt.Fprintln(writer, ar2) // => [1 2 3 0 0]

	ar2[4] = 99
	fmt.Fprintln(writer, ar2) //  => [1 2 3 0 99]

	sl1 := ar1[0:2]
	fmt.Fprintln(writer, sl1) // => [1 2]

	sl2 := ar2[3:]
	fmt.Fprintln(writer, sl2) // => [0 99]

	sl2[1] = 100
	fmt.Fprintln(writer, sl2) // => [0 100]
	fmt.Fprintln(writer, ar2) // => [1 2 3 0 100]
}

func slice(writer http.ResponseWriter, req *http.Request) {
	sl1 := []int{1, 2, 3, 4, 5} // スライスリテラル
	var rad float64

	for _, v := range sl1 {
		rad = float64(v) * math.Pi / 180.0
		fmt.Fprintf(writer, "sin %d = %.3f\n", v, math.Sin(rad))
	}

	sl1 = append(sl1, 10, 20, 30)
	fmt.Fprintln(writer, sl1) // => [1 2 3 4 5 10 20 30]

	sl2 := sl1[0:2]
	fmt.Fprintln(writer, sl2) // =>
}

func main() {
	http.HandleFunc("/hello", hello)
	http.HandleFunc("/algebra", algebra)
	http.HandleFunc("/math", mathF)
	http.HandleFunc("/array", array)
	http.HandleFunc("/slice", slice)
	http.ListenAndServe(":8090", nil)
}

// $ go build server -> ./server
