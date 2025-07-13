// https://exercism.org/tracks/go/exercises/gigasecond

package gigasecond

import "time"

func AddGigasecond(t time.Time) time.Time {
	gigasecond := time.Duration(1_000_000_000)
	return t.Add(time.Second * gigasecond)
}
