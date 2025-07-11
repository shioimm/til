package main

import (
	"log"
	"net/http"
	"net/http/httputil"
)

func main() {
	client := http.Client{}
	req, err := http.NewRequest("DELETE", "http://localhost:18888", nil)
	if err != nil { panic(err) }

	res, err := client.Do(req)
	if err != nil { panic(err) }

	dump, err := httputil.DumpResponse(res, true)
	if err != nil { panic(err) }

	log.Println(string(dump))
}
