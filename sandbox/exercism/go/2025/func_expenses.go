// https://exercism.org/tracks/go/exercises/expenses

package expenses

type Record struct {
	Day      int
	Amount   float64
	Category string
}

type DaysPeriod struct {
	From int
	To   int
}

func Filter(in []Record, predicate func(Record) bool) []Record {
	var out []Record

	for _, record := range in {
		if predicate(record) {
			out = append(out, record)
		}
	}

	return out
}

func ByDaysPeriod(p DaysPeriod) func(Record) bool {
	return func(record Record) bool {
		return record.Day >= p.From && record.Day <= p.To
	}
}
