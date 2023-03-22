class_name StateFactory

var states


func _init():
	states = {
		"moving" : MovingState,
		"armed" : ArmedState,
		"unarmed" : UnarmedState,
		"shooting" : ShootingState,
		"hooked" : HookedState,
		"grabbing" : GrabbingState,
	}


func get_state(state_name):
	if states.has(state_name):
		return states.get(state_name).new()
	else:
		printerr("No state ", state_name, " in state factory!")
