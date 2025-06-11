// https://exercism.org/tracks/go/exercises/election-day

package electionday

func NewVoteCounter(initialVotes int) *int {
	votes := initialVotes;
	return &votes
}

func VoteCount(counter *int) int {
	if counter == nil { return 0 }

	return *counter
}

func IncrementVoteCount(counter *int, increment int) *int {
	*counter += increment
	return counter
}

func NewElectionResult(candidateName string, votes int) *ElectionResult {
	return &ElectionResult{Name: candidateName, Votes: votes}
}

func DisplayResult(result *ElectionResult) string {
	return fmt.Sprintf("%s (%d)", result.Name, result.Votes)
}
