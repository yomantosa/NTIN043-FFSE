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
  destination: one Node,
  status: one Status,
  carrying: lone Package -- The package the robot is currently carrying (if any)
}

abstract sig Status {}
one sig Idle, Moving, Loading, Unloading extends Status {}

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

-- Command to check the system's behavior
run AvoidTrafficJam {
  -- Multiple robots move without collisions or exceeding path capacity
  some r1, r2: Robot |
    r1 != r2 and
    some t1, t2: Task |
      PlanRoute[r1, t1] and PlanRoute[r2, t2]
}
