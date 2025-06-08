// https://exercism.org/tracks/go/exercises/need-for-speed

package speed

type Car struct {
	speed int
	batteryDrain int
	battery int
	distance int
}

func NewCar(speed, batteryDrain int) Car {
	return Car{ speed: speed, batteryDrain: batteryDrain, battery: 100, distance: 0 }
}

type Track struct {
	distance int
}

func NewTrack(distance int) Track {
	return Track{ distance: distance }
}

func Drive(car Car) Car {
	battery := car.battery - car.batteryDrain

	if battery >= 0 {
		car.battery = battery
		car.distance += car.speed
	}

	return car
}

func CanFinish(car Car, track Track) bool {
	canRun := car.battery / car.batteryDrain
	maxDistance := car.speed * canRun

	return maxDistance - track.distance >= 0
}
