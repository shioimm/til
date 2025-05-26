// https://exercism.org/tracks/go/exercises/welcome-to-tech-palace

package techpalace

import "strings"

func WelcomeMessage(customer string) string {
	return "Welcome to the Tech Palace, " + strings.ToUpper(customer)
}

func AddBorder(welcomeMsg string, numStarsPerLine int) string {
	stars := strings.Repeat("*", numStarsPerLine)
	return stars + "\n" + welcomeMsg + "\n" + stars
}

func CleanupMessage(oldMsg string) string {
	return strings.Trim(oldMsg, "* \n")
}
