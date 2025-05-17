package main

import "fmt"

func main() {
	type MailCategory int

	const (
		Unknown MailCategory = iota
		Personal
		Spam
		Social
		Advertisements
	)

	fmt.Println(Unknown)
	fmt.Println(Personal)
	fmt.Println(Spam)
	fmt.Println(Social)
	fmt.Println(Advertisements)
}
