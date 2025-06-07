// https://exercism.org/tracks/go/exercises/weather-forecast

// Package weather provides tools to forecast
// the current weather condition of various cities.
package weather

// CurrentCondition represents the current weather condition.
var CurrentCondition string
// CurrentLocation represents the current city.
var CurrentLocation string

// Forecast returns an string describing the current weather condition in the current city.
func Forecast(city, condition string) string {
	CurrentLocation, CurrentCondition = city, condition
	return CurrentLocation + " - current weather condition: " + CurrentCondition
}
