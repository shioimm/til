package main

import (
	"log"
	"net/http"
	"net/http/httputil"
)

func main() {
	transport := &http.Transport{}
	transport.RegisterProtocol("file", http.NewFileTransport(http.Dir(".")))

	client := http.Client{
		Transport: transport,
	}

	res, err := client.Get("file://./main.go")
	if err != nil { panic(err) }

	dump, err := httputil.DumpResponse(res, true)
	if err != nil { panic(err) }

	log.Println(string(dump))
}
