// https://exercism.org/tracks/go/exercises/lasagna-master

package lasagna

func PreparationTime(layers []string, time int) int {
	if time == 0 { time = 2 }

	return len(layers) * time
}

func Quantities(layers []string) (int, float64) {
	numberOfNoodles := 0
	numberOfSource := 0

	for _, ingredient := range layers {
		if ingredient == "sauce" {
			numberOfSource++
		} else if ingredient == "noodles" {
			numberOfNoodles++
		}
	}

	return numberOfNoodles * 50, float64(numberOfSource) * 0.2
}

func AddSecretIngredient(friendsList []string, myList []string) []string {
	secretIngredient := friendsList[len(friendsList) - 1]
	myList[len(myList) - 1] = secretIngredient

	return myList
}

func ScaleRecipe(inputList []float64, portions int) []float64 {
	outputList := make([]float64, len(inputList))

	for i, _ := range inputList {
		outputList[i] = inputList[i] / 2.0 * float64(portions)
	}

	return outputList
}
