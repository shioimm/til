package main

import "fmt"

type LinkedList struct {
	Value any
	Next *LinkedList
}

func (ll *LinkedList) Insert(pos int, val any) *LinkedList {
	if ll == nil || pos == 0 {
		return &LinkedList{
			Value: val,
			Next: ll,
		}
	}
	ll.Next = ll.Next.Insert(pos - 1, val)
	return ll
}

func main() {
	var ll LinkedList
	ll.Insert(1, 1)
	ll.Insert(2, "2")

	fmt.Println(ll.Value)
	fmt.Println(ll.Next.Value)
	fmt.Println(ll.Next.Next.Value)
}
