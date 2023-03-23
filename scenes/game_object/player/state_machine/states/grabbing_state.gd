extends BaseState
class_name GrabbingState


func _ready():
	print("GrabbingState")
	PlayerEvents.emit_start_grabbing_request(controller_id)


func grip_released():
	PlayerEvents.emit_stop_grabbing_request(controller_id)
	change_state.call("unarmed")


