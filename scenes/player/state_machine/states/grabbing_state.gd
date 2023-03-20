extends BaseState
class_name GrabbingState


func _ready():
	print("GrabbingState")
	GameEvents.emit_start_grabbing_request(controller_id)


func grip_released():
	GameEvents.emit_stop_grabbing_request(controller_id)
	change_state.call("unarmed")


