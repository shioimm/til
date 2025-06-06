// https://exercism.org/tracks/go/exercises/gross-store
package gross

func Units() map[string]int {
	units := map[string]int{
		"quarter_of_a_dozen": 3,
		"half_of_a_dozen": 6,
		"dozen": 12,
		"small_gross": 120,
		"gross": 144,
		"great_gross": 1728,
	}

	return units
}

func NewBill() map[string]int {
	return map[string]int{}
}

func AddItem(bill, units map[string]int, item, unit string) bool {
	value, ok := units[unit]

	if ok { bill[item] += value }

	return ok
}

func RemoveItem(bill, units map[string]int, item, unit string) bool {
	_, billOk := bill[item]
	unitsValue, unitsOk := units[unit]

	if !billOk || !unitsOk { return false }

	rem := bill[item] - unitsValue

	if rem < 0 { return false }

	if rem == 0 {
		delete(bill, item)
		return true
	}

	bill[item] -= unitsValue

	return true
}

func GetItem(bill map[string]int, item string) (int, bool) {
	billItem, ok := bill[item]

	return billItem, ok
}
