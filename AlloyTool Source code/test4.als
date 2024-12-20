sig Node {
  id: Int,
  zone: one Zone -- Zones within the warehouse (e.g., storage, staging, shipping)
}

sig Path {
  id: Int,
  start: one Node,
  end: one Node,
  capacity: Int -- Maximum number of robots that can use the path simultaneously
}

sig Package {
  id: Int,
  weight: Int,
  location: lone Node -- Either a specific node or being carried by a robot
}

sig Robot {
  id: Int,
  capacity: Int, -- How much weight the robot can carry
  currentNode: one Node,
  destination: one Node,
  status: one Status,
  carrying: set Package, -- The packages the robot is currently carrying (if any)
  energy: Int -- Energy level of the robot
}

abstract sig Status {}
one sig Idle, Moving, Loading, Unloading, Charging extends Status {}

sig Employee {
  id: Int,
  role: one Role,
  location: one Node
}

abstract sig Role {}
one sig Supervisor, Operator extends Role {}

sig Task {
  robot: one Robot,
  packages: set Package,
  destination: one Node
}

abstract sig Zone {}
one sig Storage, Staging, Shipping extends Zone {}

-- Facts
fact NonNegativeIDs {
  -- Ensure all IDs are non-negative
  all n: Node, p: Path, pkg: Package, r: Robot, e: Employee |
    n.id >= 0 and p.id >= 0 and pkg.id >= 0 and r.id >= 0 and e.id >= 0
}

fact PathCapacity {
  -- Robots cannot exceed path capacity
  all p: Path | # {r: Robot | r.currentNode = p.start and r.status = Moving} <= p.capacity
}

fact TrafficAvoidance {
  -- No two robots occupy the same node at the same time
  all r1, r2: Robot | r1 != r2 => r1.currentNode != r2.currentNode
}

fact PackageAssignment {
  -- A robot can carry packages only if their total weight is within its capacity
  all r: Robot | (sum p: r.carrying | p.weight) <= r.capacity

  -- Packages must have a valid location (either with a robot or at a node)
  all p: Package | some r: Robot | p in r.carrying or some n: Node | p.location = n
}

fact EnergyCheck {
  -- Robots must have enough energy to perform tasks
  all r: Robot | r.energy > 0
}

pred LoadPackages[r: Robot, ps: set Package] {
  -- Robot must be at the same node as the packages and not exceed its capacity
  all p: ps | p.location = r.currentNode
  
  -- Ensure total weight is within capacity
  (sum p: ps | p.weight) <= r.capacity

  -- Robot picks up the packages
  all p: ps | p.location = none and p in r.carrying
}

pred DropPackages[r: Robot, ps: set Package] {
  -- Robot must be carrying the packages
  all p: ps | p in r.carrying

  -- Packages are dropped at the robot's current location
  all p: ps | p.location = r.currentNode and p !in r.carrying
}

pred PlanRoute[r: Robot, t: Task] {
  -- Robot must reach its destination by following valid paths
  r = t.robot and r.status = Moving and 
  some p: Path | r.currentNode = p.start and t.destination = p.end
}

pred ChargeRobot[r: Robot] {
  -- Robot must be idle or at a charging station
  r.status = Charging

  -- Robot's energy increases
  r.energy < 100
}

pred AssignDynamicTask[t: Task] {
  -- Ensure the robot assigned to the task is idle and can handle the packages
  t.robot.status = Idle
  (sum p: t.packages | p.weight) <= t.robot.capacity

  -- All packages in the task must be located at the robot's current node
  all p: t.packages | p.location = t.robot.currentNode
}

pred EmployeeAssignTask[e: Employee, t: Task] {
  -- Only a Supervisor can assign tasks
  e.role = Supervisor

  -- Assign a task to a robot
  AssignDynamicTask[t]
}

pred InitialSetup {
  one n1, n2: Node | n1.zone = Storage and n2.zone = Shipping
//   one p: Path | p.start = n1 and p.end = n2 and p.capacity = 2
//   one pkg: Package | pkg.location = n1
//   one r: Robot | r.currentNode = n1 and r.capacity = 10 and r.energy = 100
//   one t: Task | t.robot = r and t.packages = pkg and t.destination = n2
//   one e: Employee | e.role = Supervisor and e.location = n1
}

run WarehouseSimulation { InitialSetup }

-- Command to simulate enhanced warehouse behavior
run AssignTasks {
	some t: Task, e: Employee |
	EmployeeAssignTask[e, t] 
}

run LoadingPackages {
    some r: Robot, ps: set Package |
    LoadPackages[r, ps]
}

run WarehouseSimulation {
  some r: Robot, ps: set Package, t: Task |
    
    LoadPackages[r, ps] and
    PlanRoute[r, t] and
    DropPackages[r, ps]
}
