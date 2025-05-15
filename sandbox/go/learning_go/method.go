package main

import (
	"fmt"
	"time"
)

type Type struct {
	Name string
	No int
}

func (t Type) Pp() string {
	return fmt.Sprintf("%d: %s", t.No, t.Name)
}

type Counter struct {
	total int
	lastUpdated time.Time
}

func (c *Counter) Increment() {
	c.total++
	c.lastUpdated = time.Now()
}

func (c Counter) Pp() string {
	return fmt.Sprintf("%d, updated at %s", c.total, c.lastUpdated)
}

func doUpdateWrong(c Counter) {
	c.Increment()
	fmt.Println("NG ", c.Pp())
}

func doUpdateRight(c *Counter) {
	c.Increment()
	fmt.Println("OK ", c.Pp())
}

func main() {
	foo := Type{
		Name: "Foo",
		No: 1,
	}

	fmt.Println(foo.Pp())

	var c Counter
	fmt.Println(c.Pp())
	c.Increment()
	fmt.Println(c.Pp())

	doUpdateWrong(c)
	fmt.Println("main ", c.Pp())
	doUpdateRight(&c)
	fmt.Println("main ", c.Pp())
}
