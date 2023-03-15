extends MovingState
class_name HookedState

func _ready():
	GameEvents.hook_finished_retracting.connect(on_hook_finished_retracting)
	
	GameEvents.emit_start_hooking_request(controller_id)


func trigger_released():
	GameEvents.emit_stop_hooking_request(controller_id)


func on_hook_finished_retracting(signal_controller_id: int):
	if controller_id == signal_controller_id:
		change_state.call("unarmed")
