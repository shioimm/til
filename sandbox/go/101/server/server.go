// https://www.kohgakusha.co.jp/books/detail/978-4-7775-2239-2

package main

import (
	"fmt"
	"net/http"
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

func main() {
	http.HandleFunc("/hello", hello)
	http.HandleFunc("/algebra", algebra)
	http.ListenAndServe(":8090", nil)
}

// $ go build server -> ./server
