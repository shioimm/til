// https://exercism.org/tracks/go/exercises/party-robot

package partyrobot

import "fmt"

func Welcome(name string) string {
	return fmt.Sprintf("Welcome to my party, %s!", name)
}

func HappyBirthday(name string, age int) string {
	return fmt.Sprintf("Happy birthday %s! You are now %d years old!", name, age)
}

func AssignTable(name string, table int, neighbor, direction string, distance float64) string {
	welcome_msg  := Welcome(name)
	assigned_msg := fmt.Sprintf("You have been assigned to table %03d. ", table)
	table_msg    := fmt.Sprintf("Your table is %s, exactly %.1f meters from here.\n", direction, distance)
	neighbor_msg := fmt.Sprintf("You will be sitting next to %s.", neighbor)

	return welcome_msg + "\n" + assigned_msg + table_msg + neighbor_msg
}
