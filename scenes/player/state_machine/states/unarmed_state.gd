extends MovingState
class_name UnarmedState


func _ready():
	print("Unarmed State")


func thumbstick_pressed():
	change_state.call("armed")


func trigger_pressed():
	GameEvents.emit_start_hooking_request(controller_id)


func trigger_released():
	GameEvents.emit_stop_hooking_request(controller_id)


func grab():
	pass
