package main

import "fmt"

type Status int

const Invalid = 1

type StatusErr struct {
	Status Status
	Message string
}

func (e StatusErr) Error() string {
	return e.Message
}

func RaiseError() (error) {
	return StatusErr{
		Status: Invalid,
		Message: "Invalid",
	}
}

func main() {
	err := RaiseError()
	serr, status := err.(StatusErr)
	if status {
		fmt.Printf("%d: %s\n", serr.Status, serr.Message)
	}
}
