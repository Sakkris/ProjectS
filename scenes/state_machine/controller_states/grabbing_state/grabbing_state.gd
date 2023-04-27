extends ControllerState
class_name GrabbingState


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func enter(_msg := {}) -> void:
	$"../../AimSight".disable_sight()
	ability_manager.use_ability("Grab")


func exit() -> void:
	$"../../AimSight".enable_sight()
	await ability_manager.stop_ability("Grab")


func handle_input_released(button: String):
	if button == "grip_click" && state_machine.state.name == "Grabbing":
		state_machine.transition_to("Unarmed")

