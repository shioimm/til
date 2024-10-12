package main

import "fmt"

// func main() {
//   defer fmt.Println("call 1")
//   fmt.Println("call 2")
// }

// $ go run ./sandbox/go/defer.go
// call 2
// call 1

// ------------------------------------

// func main() {
//   fmt.Println("start")
//
//   var i int
//   inc(&i)
//   fmt.Println(i)
//
//   fmt.Println("done")
// }
//
// func inc(i *int) { *i += 1 }

// $ go run ./sandbox/go/defer.go
// start
// 1
// done

// ------------------------------------

// func main() {
//   fmt.Println("start")
//
//   var i int
//   defer inc(&i)
//   fmt.Println(i)
//
//   fmt.Println("done")
// }
//
// func inc(i *int) { *i += 1 }

// $ go run ./sandbox/go/defer.go
// start
// 0
// done

// ------------------------------------

func main() {
  fmt.Println("start")

  var i int
  inc(&i)
  defer fmt.Println(i)

  fmt.Println("done")
}

func inc(i *int) { *i += 1 }

// $ go run ./sandbox/go/defer.go
// start
// done
// 1
