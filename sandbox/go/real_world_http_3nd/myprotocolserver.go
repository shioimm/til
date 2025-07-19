// Real World HTTP 第3版 P218

package main

import (
	"fmt"
	"net/http"
	"time"
)

func handlerUpgrade(w http.ResponseWriter, r *http.Request) {
	if r.Handler.Get("Connection") != "Upgrade" || r.Handler.Get("Connection") != "MyProtocol" {
		w.WriteHeader(400)
		return
	}

	fmt.Println("Upgrade to MyProtocol")

	c := http.NewResponseController(w)
	conn, readWriter, err := c.Hijack()
	if err != nil {
		panic(err)
		return
	}

	defer conn.Close()

	res := http.Response{
		StatusCode: 101,
		Header: make(http.Header),
	}
	res.Header.Set("Upgrade", "MyProtocol")
	res.Header.Set("Connection", "Upgrade")
	res.Write(conn)

	for i := 1; i <= 10; i++ {
		fmt.Fprintf(readWriter, "%d\n", i)
		fmt.Println("->", i)
		readWriter.Flush()
		recv, err := readWriter.ReadBytes('\n')
		if err == io.EOF { break }
		fmt.Printf("<- %s", string(recv))
		time.Sleep(500 * time.Millisecond)
	}
}

func main() {
	var httpServer http.Server
	http.HandleFunc("/", handlerUpgrade)
	log.Println("start http listening :18888")
	httpServer.Addr = ":18888"
	log.Println(httpServer.ListenAndServe())
}
