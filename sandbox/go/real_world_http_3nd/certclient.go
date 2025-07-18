package main

import (
	"crypto/tls"
	"crypto/x509"
	"net/http"
	"net/http/httputil"
	"log"
	"os"
)

func main() {
	cert, err := os.LoadX509KeyPair("client.crt", "client.key")
	if err != nil { panic(err) }

	client := &http.Client{
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{
				Certificates: []tls.Certificate{cert},
			},
		},
	}

	res, err := client.Get("http://localhost:18443")
	if err != nil { panic(err) }

	defer res.Body.Close()

	dump, err := httputil.DumpResponse(res, true)
	if err != nil { panic(err) }

	log.Println(string(dump))
}
