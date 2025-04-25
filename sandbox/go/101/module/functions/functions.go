// https://www.kohgakusha.co.jp/books/detail/978-4-7775-2239-2
// $ go mod init functions
package functions

func Add(x int, y int) int {
	return x + y
}

func Sub(x int, y int) (int, float64) {
	return x, float64(y)
}

func AddAll(sl []int, x int) {
	for i := 0; i < len(sl); i++ {
		sl[i] += x
	}
}

func AddAndCopy(sl []int, x int) []int {
	cp := []int{}

	for i := 0; i < len(sl); i++ {
		cp = append(cp, sl[i] + x)
	}

	return cp
}
