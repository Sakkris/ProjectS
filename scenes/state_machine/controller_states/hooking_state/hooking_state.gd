extends MovingStateR
class_name HookingStateR


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func enter(_msg := {}) -> void:
	await ability_manager.use_ability("Hook")
	state_machine.transition_to("Unarmed")


func exit() -> void:
	pass


func handle_input_released(button: String):
	super.handle_input_released(button)
	
	if button == "trigger_click":
		ability_manager.stop_ability("Hook")
		
