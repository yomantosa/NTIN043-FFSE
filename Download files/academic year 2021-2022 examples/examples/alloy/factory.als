// model of a car factory
module factory

// type without internal structure
sig Name {}

abstract sig Building {}

sig ManagementOffice extends Building {}

sig FactoryBuilding extends Building {
  lines: set ProductionLine
}

sig Employee {
  name : one Name,
  location : lone Building
}

// we have different kinds of employees here

sig Accountant extends Employee {}

sig Worker extends Employee {
  worksAt : ProductionLine
}

sig Engineer extends Employee {
  expertIn: Expertise 
}

// simulating enum
sig Expertise {}
one sig ExpEngine extends Expertise {}
one sig ExpSteering extends Expertise {}

sig ProductionLine {
  assigned : set Worker,
  location: FactoryBuilding
}

one sig Director extends Employee {} { no location }

sig Project {
  supervisor : one (Employee - Worker),
  team : set (Employee - Director)
}

fact {
  all p : ProductionLine, w : p.assigned | w.worksAt = p
}

// note that signature Employee is not abstract
fact { Accountant + Worker + Engineer + Director = Employee }

fact { all p : ProductionLine, w : p.assigned | w.location = p.location }

pred myinst {}
run myinst for exactly 2 Name, 1 Building, 5 Employee, 3 Worker, 2 ProductionLine, 2 Expertise, 1 Project
run myinst for 3 but 2 ProductionLine, 2 Accountant

assert correctLocations {
  all w : Worker | w.location in FactoryBuilding
}

check correctLocations for 3

//fact { all w : Worker | some pl : ProductionLine | w.worksAt = pl and w in pl.assigned }

//fact { #Director > 2 }

// TODO
// model these entities (concepts):
//     assignment of tasks
//     schedule
//     worker shifts
//     robots (of several types)
// attributes for robots: to which building they belong
// constraints: proper number of robots and workers at a production line
