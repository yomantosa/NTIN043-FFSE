sig Node {}

sig Path {
  start: one Node,
  end: one Node,
  capacity: Int -- Maximum number of robots that can use the path simultaneously
}

sig Package {
  id: Int,
  weight: Int,
  location: one Node
}

sig Robot {
  id: Int,
  capacity: Int, -- How much weight the robot can carry
  currentNode: one Node,
  destination: lone Node,
  carrying: lone Package -- The package the robot is currently carrying (if any)
}

sig Task {
  robot: one Robot,
  package: lone Package,
  destination: one Node
}

-- Facts
fact PathCapacity {
  -- Robots cannot exceed path capacity
  all p: Path | # {r: Robot | r.currentNode = p.start} <= p.capacity
}

fact CarryingConstraints {
  -- A robot can carry a package only within its capacity
  all r: Robot | r.carrying != none => r.carrying.weight <= r.capacity

  -- A package must always have a valid location
  all p: Package | some r: Robot | r.carrying = p or some n: Node | p.location = n
}

fact PackageLocationConsistency {
  -- If a robot is carrying a package, their locations must match
  all r: Robot | r.carrying != none => r.carrying.location = r.currentNode
}

fact TrafficAvoidance {
  -- Robots cannot occupy the same node
  all r1, r2: Robot | r1 != r2 => r1.currentNode != r2.currentNode
}

-- Predicates
pred PlanRoute[r: Robot, t: Task] {
  -- A robot moves toward its destination
  some p: Path | p.start = r.currentNode and p.end = t.destination
}

pred PickUp[r: Robot, p: Package] {
  -- A robot picks up a package if it's at the same location
  p.location = r.currentNode and no r.carrying
}

pred DropOff[r: Robot, p: Package, n: Node] {
  -- A robot drops off a package at the specified node
  r.carrying = p and r.currentNode = n
}

-- New Predicate
pred MovePackage {
  -- Robot picks up the package
  PickUp[Robot1, Package1] and
  -- Robot follows the route to its destination
  PlanRoute[Robot1, Task1] and
  -- Robot drops off the package
  DropOff[Robot1, Package1, NodeB]
}

-- Example instances for Nodes
one sig NodeA, NodeB, NodeC extends Node {}

-- Example instances for Paths
one sig Path1 extends Path {}
fact DefinePath1 {
  Path1.start = NodeA
  Path1.end = NodeB
  Path1.capacity = 2
}

one sig Path2 extends Path {}
fact DefinePath2 {
  Path2.start = NodeB
  Path2.end = NodeC
  Path2.capacity = 1
}

-- Example instances for Packages
one sig Package1 extends Package {}
fact DefinePackage1 {
  Package1.id = 1
  Package1.weight = 5
  Package1.location = NodeA
}

-- Example instances for Robots
one sig Robot1 extends Robot {}
fact DefineRobot1 {
  Robot1.id = 1
  Robot1.capacity = 10
  Robot1.currentNode = NodeA
}

-- Tasks for Robots
one sig Task1 extends Task {}
fact DefineTask1 {
  Task1.robot = Robot1
  Task1.package = Package1
  Task1.destination = NodeB
}

-- Command to test with the new setup
run MovePackage for exactly 3 Node, 2 Path, 1 Robot, 1 Package, 1 Task
