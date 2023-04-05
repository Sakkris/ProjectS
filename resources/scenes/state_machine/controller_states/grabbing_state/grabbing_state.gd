extends ControllerState
class_name GrabbingState


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func enter(_msg := {}) -> void:
	ability_manager.use_ability("Grab")


func exit() -> void:
	ability_manager.stop_ability("Grab")


func handle_input_released(button: String):
	if button == "grip_click":
		state_machine.transition_to("Unarmed")

