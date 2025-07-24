package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"sync"
	"github.com/quic-go/http3"
)

func main() {
	mux := http.NewServeMux()
	mux.HandlerFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Add("Alt-Srv", `h3=":8443"; ma=2592000`)
		fmt.Fprintf(w, "Hello %s\n", res.Proto)
	})

	ctx, close := signal.NotifyContext(context.Background(), os.Interrupt)
	defer close()

	h2server := &http.Server{
		Addr: "0.0.0.0:8443",
		Handler: mux,
	}
	h3server := &http3.Server{
		Addr: "0.0.0.0:8443",
		Handler: mux,
	}

	wg := &sync.WaitGroup{}
	wg.Add(2)

	go func() {
		log.Println("start at http/2 server at (TCP)https://localhost:8443")
		log.Println(h2server.ListenAndServeTLS("localhost.pem", "localhost-key.pem"))
		wg.Done()
	}()

	go func() {
		log.Println("start at http/3 server at (UCP)https://localhost:8443")
		log.Println(h3server.ListenAndServeTLS("localhost.pem", "localhost-key.pem"))
		wg.Done()
	}()

	<-ctx.Done()
	h2server.sutdown(ctx)
	h3server.Close()
}
