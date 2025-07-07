package main

import (
	"io"
	"log"
	"net/http"
)

func main() {
	res, err := http.Get("http://localhost:18888")

	if err != nil { panic(err) }

	defer res.Body.Close()
	body, err := io.ReadAll(res.Body)

	if err != nil { panic(err) }

	log.Println(string(body))
	log.Println("Status:", res.Status)
	log.Println("StatusCode:", res.StatusCode)
	log.Println("Header:", res.Header)
	log.Println("Content-Length", res.Header.Get("Content-Length"))
}
