// https://exercism.org/tracks/go/exercises/card-tricks

package cards

func FavoriteCards() []int {
	return []int{2, 6, 9}
}

func GetItem(slice []int, index int) int {
	if index >= len(slice) || 0 > index {
		return -1
	}

	return slice[index]
}

func SetItem(slice []int, index, value int) []int {
	if GetItem(slice, index) == -1 {
		slice = append(slice, value)
	} else {
		slice[index] = value
	}

	return slice
}
