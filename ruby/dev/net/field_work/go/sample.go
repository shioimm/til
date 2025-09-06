// https://pkg.go.dev/net/http?utm_source=chatgpt.com

package main

import (
	"net/http"
	"io"
	"fmt"
)

func main() {
	req, err := http.NewRequest("GET", "https://example.com", nil)

	if err != nil {
		panic(err)
	}

	req.Header.Set("Accept", "text/html")

	res, err := http.DefaultClient.Do(req)

	if err != nil {
		panic(err)
	}

	defer res.Body.Close()

	body, _ := io.ReadAll(res.Body)
	fmt.Println("GET status:", res.Status)
	fmt.Println("GET body:", string(body))

	res, err = http.Get("https://example.com")

	if err != nil {
		panic(err)
	}

	body, _ = io.ReadAll(res.Body)
	fmt.Println("GET status:", res.Status)
	fmt.Println("GET body:", string(body))
}
