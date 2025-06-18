// https://exercism.org/tracks/go/exercises/census

package census

type Resident struct {
	Name    string
	Age     int
	Address map[string]string
}

func NewResident(name string, age int, address map[string]string) *Resident {
	return &Resident{
		Name: name,
		Age: age,
		Address: address,
	}
}

func (r *Resident) HasRequiredInfo() bool {
	if r.Name == "" || r.Address == nil { return false }

	address, ok := r.Address["street"]
	if !ok || (address == "") { return false }

	return true
}

func (r *Resident) Delete() {
	r.Name = ""
	r.Age = 0

	var address map[string]string
	r.Address = address
}

func Count(residents []*Resident) int {
	count := 0

	for _, r := range residents {
		if r.HasRequiredInfo() {
			count++
		}
	}

	return count
}
