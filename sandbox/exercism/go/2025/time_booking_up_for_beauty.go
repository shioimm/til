// https://exercism.org/tracks/go/exercises/booking-up-for-beauty

package booking

import "time"

func Schedule(date string) time.Time {
	ret, _ := time.Parse("1/2/2006 15:04:05", date)
	return ret
}

func HasPassed(date string) bool {
	t, _ := time.Parse("January 2, 2006 15:04:05", date)
	now := time.Now()

	return t.Before(now)
}

func IsAfternoonAppointment(date string) bool {
	t, _ := time.Parse("Monday, January 2, 2006 15:04:05", date)
	hour := t.Hour()

	return hour >= 12 && 18 > hour
}

func Description(date string) string {
	t, _ := time.Parse("1/2/2006 15:04:05", date)

	return t.Format("You have an appointment on Monday, January 2, 2006, at 15:04.")
}

func AnniversaryDate() time.Time {
	return time.Date(time.Now().Year(), time.September, 15, 0, 0, 0, 0, time.UTC)
}
