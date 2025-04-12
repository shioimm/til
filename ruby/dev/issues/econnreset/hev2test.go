package main

import (
	"fmt"
	"io"
	"net"
	"time"
)

func main() {
	conn, err := net.DialTimeout("tcp", "example.com:80", 5*time.Second)
	if err != nil {
		panic(err)
	}
	defer conn.Close()

	_, err = conn.Write([]byte("GET / HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n"))
	if err != nil {
		panic(err)
	}

	resp, err := io.ReadAll(conn)
	if err != nil {
		panic(err)
	}

	fmt.Println(string(resp))
}
