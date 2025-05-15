package main

import "fmt"

type Type struct {
	Name string
	No int
}

func (t Type) Pp() string {
	return fmt.Sprintf("%d: %s", t.No, t.Name)
}

func main() {
	foo := Type{
		Name: "Foo",
		No: 1,
	}

	fmt.Println(foo.Pp())
}
