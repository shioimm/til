// https://exercism.org/tracks/go/exercises/rna-transcription

package strand

func ToRNA(dna string) string {
	mapping := map[rune]string{
		'G': "C",
		'C': "G",
		'T': "A",
		'A': "U",
	}

	strands := ""

	for _, r := range dna {
		strands += mapping[r]
	}

	return strands
}
