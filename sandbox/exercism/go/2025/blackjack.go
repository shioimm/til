// https://exercism.org/tracks/go/exercises/blackjack

package blackjack

func ParseCard(card string) int {
	switch card {
	case "ace":   return 11
	case "two":   return 2
	case "three": return 3
	case "four":  return 4
	case "five":  return 5
	case "six":   return 6
	case "seven": return 7
	case "eight": return 8
	case "nine":  return 9
	case "ten", "jack", "queen", "king": return 10
	default: return 0
	}
}

func FirstTurn(card1, card2, dealerCard string) string {
	me := ParseCard(card1) + ParseCard(card2)
	dealer := ParseCard(dealerCard)

	switch {
	case me == 22:
		return "P"
	case me == 21 && 10 > dealer:
		return "W"
	case (me == 21 && dealer >= 10) || (me >= 17 && 20 >= me) || (me >= 12 && 16 >= me && 7 > dealer):
		return "S"
	default:
		return "H"
	}
}
