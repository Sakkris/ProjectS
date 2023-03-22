extends MovingState
class_name UnarmedState


func _ready():
	print("Unarmed State")


func thumbstick_pressed():
	change_state.call("armed")


func trigger_pressed():
	change_state.call("hooked")


func grip_pressed():
	change_state.call("grabbing")
