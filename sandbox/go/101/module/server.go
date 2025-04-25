// https://www.kohgakusha.co.jp/books/detail/978-4-7775-2239-2
// $ go mod init server
// $ go mod edit -replace server/functions=./functions
// $ go mod tidy
// $ go build server.go
package main

import (
	"fmt"
	"net/http"
	"server/functions"
)

func add(writer http.ResponseWriter, req *http.Request) {
	result := functions.Add(1, 2)
	fmt.Fprintf(writer, "1 + 2 = %d\n", result)
}

func sub(writer http.ResponseWriter, req *http.Request) {
	x, y := functions.Sub(1, 2)
	fmt.Fprintf(writer, "x = %d, y = %.1f\n", x, y)
}

func main() {
	http.HandleFunc("/add", add)
	http.HandleFunc("/sub", sub)

	http.ListenAndServe(":8090", nil)
}
