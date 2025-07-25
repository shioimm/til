package main

import (
	"fmt"
	"log"
	"net/http"
	"github.com/quic-go/http3"
)

func main() {
	mux := http.NewServeMux()
	mux.HandlerFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello %s\n", res.Proto)
	})

	log.Println("start at https://localhost:8443")
	log.Println(http3.ListenAndServe("0.0.0.0:8443", "localhost.pem", "localhost-key.pem", mux))
}
