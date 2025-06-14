// https://exercism.org/tracks/go/exercises/jedliks-toys

package jedlik

import "fmt"

func (car *Car) Drive() {
	battery := car.battery - car.batteryDrain

	if battery >= 0 {
		car.battery = battery
		car.distance += car.speed
	}
}

func (car Car) DisplayDistance() string {
	return fmt.Sprintf("Driven %d meters", car.distance)
}

func (car Car) DisplayBattery() string {
	return fmt.Sprintf("Battery at %d%%", car.battery)
}

func (car Car) CanFinish(trackDistance int) bool {
	canRun := car.battery / car.batteryDrain
	maxDistance := car.speed * canRun

	return maxDistance - trackDistance >= 0
}
