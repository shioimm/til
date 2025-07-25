// Real World HTTP 第3版 P316

package main

import (
	"fmt"
	"math/big"
	"net/http"
	"os"
	"time"
)

var html []byte

func handlerHtml(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Content-Type", "text/html")
	w.Write(html)
}

func handlerPrimeSSE(w http.ResponseWriter, r *http.Request) {
	c := http.NewResponseController(w)
	ctx := r.Context()
	w.Header().Set("Content-Type", "text/event-stream")
	w.Header().Set("Cache-Control", "no-cache")
	w.Header().Set("Connection", "keep-alive")
	w.Header().Set("Access-Control-Allow-Origin", "*")

	var num int64 = 1

	for id := 1; id <= 100; id++ {
		select{
		case <- ctx.Done():
			fmt.Println("Connection closed from client")
		default:
			// do nothing
		}

		for {
			num++
			if big.NewInt(num).ProbablyPrime(20) {
				fmt.Println(num)
				fmt.Fprintf(w, "data: {\"id\": %d, \"number\": %d}\n\n", id, num)
				c.Flush()
				time.Sleep(time.Second)
				break
			}
		}
		time.Sleep(100)
	}
	fmt.Println("Connection closed from server")
}

func main() {
	var err error
	html, err = os.ReadFile("index.html")
	if err != nil { panic(err) }

	http.HandleFunc("/", handlerHtml)
	http.HandleFunc("/prime", handlerPrimeSSE)

	fmt.Println("start http listening :18888")
	err = http.ListenAndServe("localhost:18888", nil)
	fmt.Println(err)
}
