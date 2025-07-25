// Real World HTTP 第3版 P315

package main

import (
	"io"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Add("Link", "</style.css>; rel=preload; as=style")
		w.WriteHeader(http.StatusEarlyHints)
		w.Header().Add("Content-Type", "text/html")
		io.WriteString(w, `
		<!DOCTYPE html>
		<html>
			<head>
				<link rel="stylesheet" href="style.css">
			</head>
			<body>
				<div class="content">
					<span>Early Hints</span>
				</div>
			</body>
		</html>
		`)
	})

	http.HandleFunc("/style.css", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Add("Content-Type", "text/css")
		io.WriteString(w, `
		.content {
			display: block;
		}
		`)
	})

	log.Println("start http listening :18888")
	log.Println(http.ListenAndServe("localhost:18888", nil))
}
