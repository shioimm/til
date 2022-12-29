# Go

```go
package main // パッケージの定義

import ( // パッケージのインポート
  "fmt"
)

func main() {
  x := 1 + 2  // var x int = 1 + 2
  fmt.Printf("1 + 2 = %d\n", x) // 1 + 2 = 3

  var xP *int = &x
  fmt.Println(xP)  // xのアドレス番地

  *xP += 1
  fmt.Println(x)  // 101
}
```
