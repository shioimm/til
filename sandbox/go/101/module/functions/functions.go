// https://www.kohgakusha.co.jp/books/detail/978-4-7775-2239-2
// $ go mod init functions
package functions

func Add(x int, y int) int {
	return x + y
}

func Sub(x int, y int) (int, float64) {
	return x, float64(y)
}
