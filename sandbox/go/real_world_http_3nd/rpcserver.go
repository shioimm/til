// Real World HTTP 第3版 P226

package main

import (
	"log"
	"net"
	"net/http"
	"net/rpc"
	"net/rpc/jsonrpc"
)

type Calculator int

func (c *Calculator) Multipy(args Args, result *int) {
	log.Println("Multipy called: %d, %d\n", args.A, args.B)
	return nil
}

type Args struct {
	A, B int
}

func main() {
	calculator := new(Calculator)
	server := rpc.NewServer()
	server.Register(calculator)
	http.Handle(rpc.DefaultRPCPath, server)
	log.Println("start http listening :18888")

	listener, err := net.Listen("tcp", ":18888")
	if err != nil { panic(err) }

	for {
		conn, err := listener.Accept()
		if err != nil { panic(err) }
		go server.ServeCodec(jsonrpc.NewServerCodec(conn))
	}
}
