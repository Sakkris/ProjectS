extends MovingState
class_name UnarmedState


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func enter(_msg := {}) -> void:
	pass


func exit() -> void:
	pass


func trigger_pressed():
	state_machine.transition_to("Hooking")


func thumbstick_pressed():
	state_machine.transition_to("Armed")


func grip_pressed():
	state_machine.transition_to("Grabbing")


func handle_input_pressed(button: String):
	match(button):
		"trigger_click":
			trigger_pressed()
		"thumbstick_click":
			thumbstick_pressed()
		"grip_click":
			grip_pressed()
	
	super.handle_input_pressed(button)
