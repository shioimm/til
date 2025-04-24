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

func main() {
	http.HandleFunc("/hello", hello)
	http.HandleFunc("/algebra", algebra)
	http.HandleFunc("/math", mathF)
	http.ListenAndServe(":8090", nil)
}

// $ go build server -> ./server
