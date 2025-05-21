package main

import (
	"fmt"
	"os"
	"errors"
)

func fileChecker(name string) error {
	f, err := os.Open(name)
	if err != nil {
		return fmt.Errorf("fileChecker: %w", err)
	}

	f.Close()
	return nil
}

func main() {
	err := fileChecker("none.txt")
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			fmt.Println("file not exists")
		}
	}
}
