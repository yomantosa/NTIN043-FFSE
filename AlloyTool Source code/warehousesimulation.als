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

fact EnergyConstraint {
  -- Robots must have energy to perform tasks, and idle or charging robots increase energy
  all r: Robot | r.energy >= 0
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
  r.energy > 0
}

-- Command to simulate warehouse operations
run WarehouseSimulation {
  some r: Robot, ps: set Package, t: Task |
    LoadPackages[r, ps] and
    PlanRoute[r, t] and
    DropPackages[r, ps]
}
