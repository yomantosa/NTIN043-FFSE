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
  carrying: set Package, -- The packages the robot is currently carrying
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

-- Facts to enforce meaningful configurations
fact NonNegativeIDs {
  -- Ensure all IDs are non-negative
  all n: Node, p: Path, pkg: Package, r: Robot, e: Employee |
    n.id >= 0 and p.id >= 0 and pkg.id >= 0 and r.id >= 0 and e.id >= 0
}

fact PathsAreValid {
  -- Ensure paths connect different nodes
  all p: Path | p.start != p.end
}

fact PackageAssignment {
  -- Packages must always exist at a node or be carried by a robot
  all p: Package | some r: Robot | p in r.carrying or some n: Node | p.location = n
}

fact RobotsHaveTasks {
  -- Ensure all robots have a task assigned and carry at least one package
  all r: Robot | some t: Task | t.robot = r and t.packages != none
}

fact RobotEnergyCheck {
  -- Robots must have energy to perform tasks
  all r: Robot | r.energy > 0
}

fact UniquePackageTask {
  -- A package can only be part of one task at a time
  all p: Package | lone t: Task | p in t.packages
}

fact RobotsCarryAssignedPackages {
  -- Robots assigned a task must carry the corresponding packages
  all t: Task | t.packages in t.robot.carrying
}

-- Supervisors can only assign tasks to robots that are idle and at the same location.
fact SupervisorsAssignTasks {
  all t: Task, e: Employee |
    e.role = Supervisor and e.location = t.robot.currentNode =>
    t.robot.status = Idle
}

-- Operators assist robots only if they are at the same location and the robot has enough energy.
fact OperatorAssistsRobots {
  all r: Robot, e: Employee |
    e.role = Operator and e.location = r.currentNode =>
    r.energy > 0
}

-- Predicates
pred LoadPackages[r: Robot, ps: set Package] {
  -- Packages must be at the robot's current node
  all p: ps | p.location = r.currentNode

  -- Packages must not exceed the robot's capacity
  (sum p: ps | p.weight) <= r.capacity

  -- Packages are picked up
  all p: ps | p.location = none and p in r.carrying
}

pred PlanRoute[r: Robot, t: Task] {
  -- Robot moves to a valid destination using paths
  r.status = Moving
  some p: Path | r.currentNode = p.start and r.destination = p.end
}

pred DropPackages[r: Robot, ps: set Package] {
  -- Robot drops the packages at its destination
  all p: ps | p in r.carrying and p.location = r.currentNode
}

pred AssignTaskBySupervisor[e: Employee, t: Task] {
  e.role = Supervisor -- Only Supervisors can assign tasks
  t.robot.status = Idle -- Robot must be idle to receive a task
  t.robot.energy > 0 -- Robot must have enough energy
  t.robot.currentNode = e.location -- Robot must be at the same node as the supervisor
}

pred OperatorHandlesPackage[e: Employee, ps: set Package, n: Node] {
  e.role = Operator -- Employee must be an operator
  e.location = n -- Operator must be at the same node as the packages
  all p: ps | p.location = n -- All packages must be at the operator's location
}

-- Commands to simulate the workflow
run WarehouseSimulation {
  some r: Robot, ps: set Package, t: Task |
    -- Load packages
    LoadPackages[r, ps] and
    -- Plan the route to destination
    PlanRoute[r, t] and
    -- Drop packages at the destination
    DropPackages[r, ps] 

}

-- Command: Simulates the workflow where a supervisor assigns a task, 
-- and an operator handles packages related to that task at the appropriate node.
run EmployeeAssignTask {
  some e1, e2: Employee, t: Task, ps: set Package, n: Node | -- There must exist employees, tasks, packages, and nodes

    AssignTaskBySupervisor[e1, t] and -- A supervisor (e1) assigns a task (t) to a robot

    OperatorHandlesPackage[e2, ps, n] and -- An operator (e2) handles packages (ps) at node (n)

    t.robot.currentNode = n and -- The robot assigned to the task (t.robot) must currently be at the node (n)

    all p: ps | p in t.packages -- All packages (ps) handled by the operator must belong to the task (t)
}
