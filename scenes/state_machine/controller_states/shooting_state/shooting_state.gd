extends MovingStateR
class_name ShootingState


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func enter(_msg := {}) -> void:
	ability_manager.use_ability("Shoot")


func exit() -> void:
	ability_manager.stop_ability("Shoot")


func handle_input_released(button: String):
	super.handle_input_released(button)
	
	if button == "trigger_click":
		state_machine.transition_to("Armed")
