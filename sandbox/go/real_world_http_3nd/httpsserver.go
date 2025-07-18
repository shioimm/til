// Real World HTTP 第3版 P210

package main

import (
	"fmt"
	"log"
	"net/http"
	"net/http/httputil"
)

func handler(w http.ResponseWriter, r *http.Request) {
	dump, err := httputil.DumpRequest(r, true)

	if err != nil {
		http.Error(w, fmt.Sprint(err), http.StatusInternalServerError)
		return
	}

	fmt.Println(string(dump))
	fmt.Fprintf(w, "<html><body>Hello</body></html>\n")
}

func main() {
	server := &httpServer{
		TLSConfig: &tls.Config{
			ClientAuth: tls.RequireAndVerifyClientCert,
			MinVersion: tls.VersionTLS12,
		},
		Addr: ":18443"
	}

	http.HandleFunc("/", handler)
	log.Println("start http listening :18443")
	err := server.ListenAndServeTLS("server.crt", "server.key", nil)
	log.Println(err)
}
