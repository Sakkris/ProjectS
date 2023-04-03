extends MovingStateR
class_name ArmedState


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func enter(_msg := {}) -> void:
	pass


func exit() -> void:
	pass


func trigger_pressed():
	pass

func on_controller_button_pressed(button: String):
	if button == "trigger_click":
		trigger_pressed()


func on_controller_button_released(button: String):
	pass
