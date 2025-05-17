package main

import "fmt"

type LogicProvider struct {}

func (lp LogicProvider) Process(data string) string {
	return data
}

type Logic interface {
	Process(data string) string
}

type Client struct {
	L Logic
}

func (c Client) Program() string {
	data := "data"
	return c.L.Process(data)
}

func main() {
	c := Client {
		L: LogicProvider{},
	}

	p := c.Program()
	fmt.Println(p)
}
