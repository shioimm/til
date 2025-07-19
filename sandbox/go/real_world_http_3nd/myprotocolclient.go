package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"time"
)

func main() {
	dialer := &net.Dialer{
		Timeout: 30 * time.Second,
		KeepAlive: 30 * time.Second,
	}

	conn, err := dialer.Dial("tcp", "localhost:18888")
	if err != nil { panic(err) }

	req, _ := http.NewRequest("GET", "http://localhost:18888/upgrade", nil)
	req.Header.Set("Connection", "Upgrade")
	req.Header.Set("Upgrade", "MyProtocol")
	err = req.Write(conn)
	if err != nil { panic(err) }

	res, err := http.ReadResponse(reader, req)
	if err != nil { panic(err) }

	log.Println("Status:" res.Status)
	log.Println("Headers:" res.Header)

	counter := 10

	for {
		data, err := reader.ReadBytes('\n')
		if err == io.EOF { break }

		fmt.Println("<-", string(bytes.TrimSpace(data)))
		fmt.Fprintf(conn, "%d\n", counter)
		counter--
	}

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
