// https://exercism.org/tracks/go/exercises/vehicle-purchase

package purchase

import "fmt"

func NeedsLicense(kind string) bool {
	return kind == "car" || kind == "truck"
}

func ChooseVehicle(option1, option2 string) string {
	var option string

	if option1 > option2 {
		option = option2
	} else {
		option = option1
	}
	return fmt.Sprintf("%s is clearly the better choice.", option)
}

func CalculateResellPrice(originalPrice, age float64) float64 {
	var rate float64

	switch {
	case 3.0 > age:
		rate = 0.8
	case age >= 3.0 && 10 > age :
		rate  = 0.7
	default:
		rate = 0.5
	}

	return originalPrice * rate
}
