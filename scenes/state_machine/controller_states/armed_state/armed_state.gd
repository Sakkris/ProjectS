extends MovingStateR
class_name ArmedState


func _ready():
	super._ready()


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func enter(_msg := {}) -> void:
	pass


func exit() -> void:
	pass


func trigger_pressed():
	state_machine.transition_to("Shooting")


func thumbstick_pressed():
	exit()
	state_machine.transition_to("Unarmed")


func grip_pressed():
	ability_manager.use_ability("Thruster")


func grip_released():
	ability_manager.stop_ability("Thruster")


func by_button_pressed():
	ability_manager.use_ability("Dash")


func on_controller_button_pressed(button: String):
	match(button):
		"trigger_click":
			trigger_pressed()
		"thumbstick_click":
			thumbstick_pressed()
		"grip_click":
			grip_pressed()
		"by_button":
			by_button_pressed()


func on_controller_button_released(button: String):
	match(button):
		"grip_click":
			grip_pressed()
