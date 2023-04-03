extends MovingStateR
class_name ShootingState


func _ready():
	super._ready()


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func enter(_msg := {}) -> void:
	ability_manager.use_ability("Shoot")


func exit() -> void:
	ability_manager.stop_ability("Shoot")
	state_machine.transition_to("Armed")


func on_controller_button_released(button: String):
	if button == "trigger_click":
		exit()
