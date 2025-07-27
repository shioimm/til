// https://exercism.org/tracks/go/exercises/space-age

package space

type Planet string

const (
	Mercury Planet = "Mercury"
	Venus   Planet = "Venus"
	Earth   Planet = "Earth"
	Mars    Planet = "Mars"
	Jupiter Planet = "Jupiter"
	Saturn  Planet = "Saturn"
	Uranus  Planet = "Uranus"
	Neptune Planet = "Neptune"
)

const SecondsPerYearOnEarth = 31557600

func Age(seconds float64, planet Planet) float64 {
	ages := map[Planet]float64{
		Mercury: SecondsPerYearOnEarth * 0.2408467,
		Venus:   SecondsPerYearOnEarth * 0.61519726,
		Earth:   SecondsPerYearOnEarth,
		Mars:    SecondsPerYearOnEarth * 1.8808158,
		Jupiter: SecondsPerYearOnEarth * 11.862615,
		Saturn:  SecondsPerYearOnEarth * 29.447498,
		Uranus:  SecondsPerYearOnEarth * 84.016846,
		Neptune: SecondsPerYearOnEarth * 164.79132,
	}

	age, ok := ages[planet]

	if !ok { return -1.000000 }

	return seconds / age
}
