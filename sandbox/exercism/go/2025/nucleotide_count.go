// https://exercism.org/tracks/go/exercises/nucleotide-count

package dna

import "errors"

type Histogram map[rune]int

type DNA string

func (d DNA) Counts() (Histogram, error) {
	h := Histogram{
		'A': 0,
		'C': 0,
		'G': 0,
		'T': 0,
	}
	runes := []rune(d)

	for _, r := range runes {
		if _, ok := h[r]; ok {
			h[r]++
		} else {
			return nil, errors.New("Invalid DNA")
		}
	}

	return h, nil
}
