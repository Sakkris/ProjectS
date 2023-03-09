extends MovingState

class_name ArmedState


func _ready():
	print("Armed State")


func thumbstick_pressed():
	change_state.call("unarmed")


func trigger_pressed():
	change_state.call("shooting")


func dash():
	pass


func thruster():
	pass
