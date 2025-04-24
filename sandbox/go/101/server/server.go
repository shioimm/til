package main

import (
	"fmt"
	"net/http"
)

func hello(writer http.ResponseWriter, req *http.Request) {
	fmt.Fprintln(writer, "hello")
}

func main() {
	http.HandleFunc("/hello", hello)
	http.ListenAndServe(":8090", nil)
}

// $ go build server -> ./server
