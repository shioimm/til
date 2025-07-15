// https://exercism.org/tracks/go/exercises/scrabble-score

package scrabble

import "strings"

func Score(word string) int {
	var letters map[string]int
	letters = make(map[string]int)
	prepareLetters(letters)

	score := 0
	for _, c := range word {
		score += letters[strings.ToUpper(string(c))]
	}

	return score
}

func prepareLetters(letters map[string]int) {
	prepareScores(letters, []string{"A", "E", "I", "O", "U", "L", "N", "R", "S", "T"}, 1)
	prepareScores(letters, []string{"D", "G"}, 2)
	prepareScores(letters, []string{"B", "C", "M", "P"}, 3)
	prepareScores(letters, []string{"F", "H", "V", "W", "Y"}, 4)
	prepareScores(letters, []string{"K"}, 5)
	prepareScores(letters, []string{"J", "X"}, 8)
	prepareScores(letters, []string{"Q", "Z"}, 10)
}

func prepareScores(letters map[string]int, chars []string, score int) {
	for _, c := range chars {
		letters[c] = score
	}
}
