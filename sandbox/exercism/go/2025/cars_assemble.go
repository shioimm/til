// https://exercism.org/tracks/go/exercises/cars-assemble

package cars

func CalculateWorkingCarsPerHour(productionRate int, successRate float64) float64 {
	return float64(productionRate) * successRate / 100
}

func CalculateWorkingCarsPerMinute(productionRate int, successRate float64) int {
	return int(CalculateWorkingCarsPerHour(productionRate, successRate)) / 60
}

func CalculateCost(carsCount int) uint {
	modCost := (carsCount / 10) * 95000
	remCost := (carsCount % 10) * 10000
	return uint(modCost + remCost)
}
