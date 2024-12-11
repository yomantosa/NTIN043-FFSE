// dynamic model of a car factory
module factorydyn

open util/ordering[FactoryState]

sig FactoryState {
  prodLines : FactoryBuilding -> set ProductionLine,
  empLocations : Employee ->lone Building,
  workerAt : Worker -> ProductionLine,
  prodLineStaff : ProductionLine ->set Worker,
  registered : set Worker
}
{
  all p : ProductionLine, w : Worker | (w in p.prodLineStaff) implies (w->p in workerAt)
  all p : ProductionLine, w : Worker | (w in p.prodLineStaff) implies (w.empLocations = p.location)
}



// type without internal structure
sig Name {}

abstract sig Building {}

sig ManagementOffice extends Building {}

sig FactoryBuilding extends Building {
}

sig Employee {
  name : one Name
}

// we have different kinds of employees here

sig Accountant extends Employee {}

sig Worker extends Employee {
}

sig Engineer extends Employee {
  expertIn: Expertise 
}

// simulating enum
sig Expertise {}
one sig ExpEngine extends Expertise {}
one sig ExpSteering extends Expertise {}

sig ProductionLine {
  location: FactoryBuilding
}

one sig Director extends Employee {} { no location }

sig Project {
  supervisor : one (Employee - Worker),
  team : set (Employee - Director)
}

// note that signature Employee is not abstract
fact { Accountant + Worker + Engineer + Director = Employee }

pred myinst {}
run myinst for exactly 1 FactoryState, 3 Name, 3 Employee, 2 Building, 1 FactoryBuilding, 2 Expertise, 2 ProductionLine, 1 Project

pred addWorker [fs1, fs2: FactoryState, w: Worker, pl: ProductionLine, b: Building] {
  b in pl.location
  fs2.empLocations = fs1.empLocations + w->b
  fs2.workerAt = fs1.workerAt + w->pl
}

assert addWorkerOK {
  all fs1, fs2: FactoryState, w: Worker, pl: ProductionLine, b: Building |
    addWorker[fs1, fs2, w, pl, b] => fs2.prodLines = fs1.prodLines
}
check addWorkerOK for 3 but 1 FactoryBuilding, 1 FactoryState

fact { no first.registered } // empty set
fact { last.registered = Worker } // everything (full set)

fact {all s1, s2: FactoryState | s2 = s1.next => (#s2.registered >= #s1.registered) }

pred myexinst {}
run myexinst for 3 but 5 FactoryState

// TODO
// define operations:
//   reallocation of workers among buildings (production lines) and shifts
//   adding new robot to a production line
