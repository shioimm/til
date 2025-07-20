// Real World HTTP 第3版 P222

package main

import (
	"fmt"
	"net/http"
	"time"
)

func handlerChunkedResponse(w http.ResponseWriter, r *http.Request) {
	c := http.NewResponseController(w)

	for i := 1; i <= 10; i++ {
		fmt.Fprintf(w, "Chunk %d\n", i)
		c.Flush()
		time.Sleep(500 * time.Millisecond)
	}
	c.Flush()
}

func main() {
	var httpServer http.Server
	http.HandleFunc("/", handlerChunkedResponse)
	log.Println("start http listening :18888")
	httpServer.Addr = ":18888"
	log.Println(httpServer.ListenAndServe())
}
