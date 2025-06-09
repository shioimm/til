// https://exercism.org/tracks/go/exercises/chessboard

package chessboard

type File []bool

type Chessboard map[string]File

func CountInFile(cb Chessboard, file string) int {
	count := 0

	for _, cell := range cb[file] {
		if cell { count++ }
	}

	return count
}

func CountInRank(cb Chessboard, rank int) int {
	if rank > 8 || rank < 1 { return 0 }

	count := 0

	for _, row := range cb {
		for i, cell := range row {
			if i + 1 == rank && cell { count++ }
		}
	}

	return count
}

func CountAll(cb Chessboard) int {
	count := 0

	for _, row := range cb {
		for range row {
			count++
		}
	}

	return count
}

func CountOccupied(cb Chessboard) int {
	count := 0

	for _, row := range cb {
		for _, cell := range row {
			if cell { count++ }
		}
	}

	return count
}
