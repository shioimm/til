// https://exercism.org/tracks/go/exercises/meteorology

package meteorology

import "fmt"

type TemperatureUnit int

const (
	Celsius    TemperatureUnit = 0
	Fahrenheit TemperatureUnit = 1
)

type Temperature struct {
	degree int
	unit   TemperatureUnit
}

type SpeedUnit int

const (
	KmPerHour    SpeedUnit = 0
	MilesPerHour SpeedUnit = 1
)

type Speed struct {
	magnitude int
	unit      SpeedUnit
}

type MeteorologyData struct {
	location      string
	temperature   Temperature
	windDirection string
	windSpeed     Speed
	humidity      int
}

func (tu TemperatureUnit) String() string {
	units := []string{"°C", "°F"}
	return units[tu]
}

func (t Temperature) String() string {
	return fmt.Sprintf("%v %v", t.degree, t.unit)
}

func (su SpeedUnit) String() string {
	units := []string{"km/h", "mph"}
	return units[su]
}

func (s Speed) String() string {
	return fmt.Sprintf("%v %v", s.magnitude, s.unit)
}

func (m MeteorologyData) String() string {
	return fmt.Sprintf(
		"%v: %v, Wind %v at %v, %v%% Humidity",
		m.location,
		m.temperature,
		m.windDirection,
		m.windSpeed,
		m.humidity,
	)
}
