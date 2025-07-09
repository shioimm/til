package main

import (
	"bytes"
	"io"
	"log"
	"mime/multipart"
	"net/http"
	"net/textproto"
	"os"
)

func main() {
	var buffer bytes.Buffer

	writer := multipart.NewWriter(&buffer)
	writer.WriteField("name", "Hanako")

	part := make(textproto.MIMEHeader)
	part.Set("Content-Type", "image/jpeg")
	part.Set("Content-Disposition", `form-data; name="thumbnail"; filename="photo.jpg"`)

	fileWriter, err := writer.CreatePart(part)

	if err != nil { panic(err) }

	readFile, err := os.Open("photo.jpg")

	if err != nil { panic(err) }

	defer readFile.Close()
	io.Copy(fileWriter, readFile)
	writer.Close()

	res, err := http.Post("http://localhost:18888", writer.FormDataContentType(), &buffer)

	if err != nil { panic(err) }

	log.Println("Status:", res.Status)
}
