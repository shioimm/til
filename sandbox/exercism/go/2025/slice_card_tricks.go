// https://exercism.org/tracks/go/exercises/card-tricks

package cards

func FavoriteCards() []int {
	return []int{2, 6, 9}
}

func GetItem(slice []int, index int) int {
	if index >= len(slice) || 0 > index { return -1 }

	return slice[index]
}

func SetItem(slice []int, index, value int) []int {
	if GetItem(slice, index) == -1 { return append(slice, value) }

	slice[index] = value
	return slice
}

func PrependItems(slice []int, values ...int) []int {
	return append(values, slice...)
}

func RemoveItem(slice []int, index int) []int {
	if GetItem(slice, index) == -1 { return slice }

	return append(slice[:index], slice[index + 1:]...)
}
