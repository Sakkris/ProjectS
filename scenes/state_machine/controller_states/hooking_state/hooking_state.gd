extends MovingState
class_name HookingState


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func enter(_msg := {}) -> void:
	await ability_manager.use_ability("Hook")
	
	if state_machine.state.name != "Paused":
		state_machine.transition_to("Unarmed")


func exit() -> void:
#	await ability_manager.stop_ability("Hook")
	pass


func handle_input_pressed(button: String):
#	if button == "grip_click":
#		ability_manager.use_ability_modifier("Hook", "Lock")
	
	super.handle_input_pressed(button)


func handle_input_released(button: String):
	if button == "trigger_click":
		ability_manager.stop_ability_modifier("Hook", "Lock")
		ability_manager.stop_ability("Hook")
#	elif button == "grip_click":
#		ability_manager.stop_ability_modifier("Hook", "Lock")
	
	super.handle_input_released(button)
