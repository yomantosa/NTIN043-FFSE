module SmartHome

// Entities
sig Room {
    sensors: set Sensor,    // Each room contains a set of sensors
    devices: set Device     // Each room contains a set of devices
}

sig Sensor {}               // Generic sensor type (e.g., motion, smoke, temperature)

sig Device {}               // Generic device type (e.g., lights, locks, thermostats)

sig Controller {
    controls: set Device,   // Devices the controller can operate
    monitors: set Sensor    // Sensors the controller can monitor
}

sig User {
    commands: set Command   // Commands issued by the user
}

// Abstract commands for system actions
abstract sig Command {}

one sig AdjustTemperature, TurnOffDevice, TriggerAlarm, LockDoors, TurnOnLights extends Command {}

// Facts to link entities
fact SensorRoomMapping {
    // Each sensor belongs to exactly one room
    all s: Sensor | one r: Room | s in r.sensors
}

fact DeviceRoomMapping {
    // Each device belongs to exactly one room
    all d: Device | one r: Room | d in r.devices
}

fact ControllerLinks {
    // A controller can only control devices in rooms and monitor sensors in rooms
    all c: Controller | 
        (c.controls in Room.devices && c.monitors in Room.sensors)
}

fact CommandsIssued {
    // Commands issued by users must be valid commands
    all u: User | u.commands in AdjustTemperature + TurnOffDevice + TriggerAlarm + LockDoors + TurnOnLights
}

// Predicate: AdjustTemperature operation
pred AdjustTemperatureOp[c: Controller, r: Room] {
    AdjustTemperature in User.commands
    some tempSensor: r.sensors | tempSensor in c.monitors
}

// Predicate: TriggerAlarm operation
pred TriggerAlarmOp[c: Controller, r: Room] {
    TriggerAlarm in User.commands
    some smokeSensor: r.sensors | smokeSensor in c.monitors
}

// Predicate: TurnOffDevice operation
pred TurnOffDeviceOp[c: Controller, r: Room] {
    TurnOffDevice in User.commands
    no motionSensor: r.sensors | motionSensor in c.monitors
}

// Assertions for validation
assert SensorRoomMappingAssertion {
    all s: Sensor | one r: Room | s in r.sensors
}

assert DeviceRoomMappingAssertion {
    all d: Device | one r: Room | d in r.devices
}

// Run and Check commands
run { AdjustTemperatureOp[Controller, Room] } for 5
run { TriggerAlarmOp[Controller, Room] } for 5
run { TurnOffDeviceOp[Controller, Room] } for 5

check SensorRoomMappingAssertion for 5
check DeviceRoomMappingAssertion for 5
