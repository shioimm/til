package main

import (
	"log"
	"net/rpc/jsonrpc"
)

type Args struct {
	A, B int
}

func main() {
	client, err := jsonrpc.Dial("tcp", "localhost:18888")
	if err != nil { panic(err) }

	var result int
	args := &Args{4, 5}
	err = client.Call("Calculator Multipy", args, &result)
	if err != nil { panic(err) }

	log.Println("4 * 5 = %d\n", result)
}
