// https://exercism.org/tracks/go/exercises/airport-robot

package airportrobot

import "fmt"

type Greeter interface {
	LanguageName() string
	Greet(name string) string
}

type Italian struct {}

func (i Italian) LanguageName() string {
	return fmt.Sprintf("Italian")
}

func (i Italian) Greet(name string) string {
	return fmt.Sprintf("Ciao %s!", name)
}

type Portuguese struct {}

func (p Portuguese) LanguageName() string {
	return fmt.Sprintf("Portuguese")
}

func (p Portuguese) Greet(name string) string {
	return fmt.Sprintf("Olá %s!", name)
}

func SayHello(name string, greeter Greeter) string {
	return fmt.Sprintf("I can speak %s: %s", greeter.LanguageName(), greeter.Greet(name))
}
