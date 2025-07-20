package main

import (
	"bufio"
	"io"
	"log"
	"net"
	"net/http"
	"strconv"
	"strings"
	"time"
)

func main() {
	dialer := &net.Dialer{
		Timeout: 30 * time.Second,
		KeepAlive: 30 * time.Second,
	}

	conn, err := dialer.Dial("tcp", "localhost:18888")
	if err != nil { panic(err) }
	defer conn.Close()

	req, _ := http.NewRequest("GET", "http://localhost:18888/chunked", nil)
	err = req.Write(conn)
	if err != nil { panic(err) }

	reader := bufio.NewReader(conn)
	res, err := http.ReadResponse(reader, req)
	if err != nil { panic(err) }
	if res.TransferEncoding[0] != "chunked" { panic("wring transfer encoding") }

	for {
		sizeStr, err := reader.ReadBytes('\n')
		if err == io.EOF { break }

		size, err := strconv.PerseInt(sizeStr[:len(sizeStr) - 2], 16, 64)
		if size == 0 { break }
		if err != nil { panic(err) }

		line := make([]byte, int(size))
		reader.Read(line)
		reader.Discard(2)
		log.Printf(" %s\n", strings.TrimSpace(string(line)))
	}
}
