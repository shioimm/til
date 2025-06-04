// https://exercism.org/tracks/go/exercises/bird-watcher

package birdwatcher

func TotalBirdCount(birdsPerDay []int) int {
	var sum int

	for _, count := range birdsPerDay {
		sum += count
	}

	return sum
}

func BirdsInWeek(birdsPerDay []int, week int) int {
	var sum int

	startAt := (week - 1) * 7
	endAt := (week) * 7

	for i := startAt; i < endAt; i++ {
		sum += birdsPerDay[i]
	}

	return sum
}

func FixBirdCountLog(birdsPerDay []int) []int {
	for i, _ := range birdsPerDay {
		if i % 2 == 0 {
			birdsPerDay[i]++
		}
	}

	return birdsPerDay
}
