package main

import (
    "fmt"
    "net"
)

func main() {
    listener, err := net.Listen("tcp", ":12345")

    if err != nil {
        fmt.Println("Error:", err)
        return
    }

    defer listener.Close()
    fmt.Println("Server is listening on port 12345...")

    for {
        conn, err := listener.Accept()

        if err != nil {
            fmt.Println("Error:", err)
            continue
        }

        fmt.Println("Connected:", conn.RemoteAddr())
        conn.Close()
    }
}
