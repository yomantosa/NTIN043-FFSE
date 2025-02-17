sig Node {
  zone: one Zone -- Zones within the warehouse (e.g., storage, staging, shipping)
}

sig Path {
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
  carrying: lone Package -- The package the robot is currently carrying (if any)
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
  package: lone Package,
  destination: one Node
}

abstract sig Zone {}
one sig Storage, Staging, Shipping extends Zone {}

-- Facts
fact PathCapacity {
  -- Robots cannot exceed path capacity
  all p: Path | # {r: Robot | r.currentNode = p.start and r.status = Moving} <= p.capacity
}

fact TrafficAvoidance {
  -- No two robots occupy the same node at the same time
  all r1, r2: Robot | r1 != r2 => r1.currentNode != r2.currentNode
}

fact PackageAssignment {
  -- A robot can carry a package only if its capacity allows
  all r: Robot | r.carrying != none => r.carrying.weight <= r.capacity

  -- Packages must have a valid location (either with a robot or at a node)
  all p: Package | some r: Robot | r.carrying = p or some n: Node | p.location = n
}

pred PlanRoute[r: Robot, t: Task] {
  -- Robot must reach its destination by following valid paths
  r = t.robot and r.status = Moving and 
  some p: Path | r.currentNode = p.start and t.destination = p.end
}

pred LoadPackage[r: Robot, p: Package] {
  -- Robot must be at the same node as the package and not already carrying one
  r.currentNode = p.location and no r.carrying

  -- Robot picks up the package
  p.location = none and r.carrying = p
}

pred DropPackage[r: Robot, p: Package] {
  -- Robot must be carrying the package
  r.carrying = p

  -- Package is dropped at the robot's current location
  p.location = r.currentNode and no r.carrying
}

pred AssignTask[e: Employee, r: Robot, t: Task] {
  -- Supervisor assigns a task to a robot
  e.role = Supervisor and t.robot = r
}

pred ChargeRobot[r: Robot] {
  -- Robot must be idle or at a charging station
  r.status = Charging
}

-- Command to simulate warehouse behavior
run SmartWarehouseSimulation {
  some r: Robot, t: Task, e: Employee |
    AssignTask[e, r, t] and
    LoadPackage[r, t.package] and
    PlanRoute[r, t] and
    DropPackage[r, t.package]
}
