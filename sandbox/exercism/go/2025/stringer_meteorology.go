// https://exercism.org/tracks/go/exercises/meteorology

package meteorology

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
