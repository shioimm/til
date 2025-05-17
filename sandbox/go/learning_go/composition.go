package main

import "fmt"

type Employee struct {
	Name string
	ID int
}

func (e Employee) Pp() string {
	return fmt.Sprintf("%d: %s", e.ID, e.Name)
}

type Manager struct {
	Employee
	Reports []Employee
}

func (m Manager) FindNewEmployees() []Employee {
	newEmployees := []Employee{
		Employee{ "Employee1", 1 },
		Employee{ "Employee2", 2 },
	}

	return newEmployees
}

func main() {
	m := Manager{
		Employee: Employee{
			Name: "Manager",
			ID: 99,
		},
		Reports: []Employee{},
	}
	m.Reports = m.FindNewEmployees()

	fmt.Println(m.Pp())
	fmt.Println(m.Reports)
}
