extends MovingState
class_name ShootingState


func _ready():
	GameEvents.emit_start_shooting_request(controller_id)
	print("Shooting state")


func trigger_released():
	GameEvents.emit_stop_shooting_request(controller_id)
	change_state.call("armed")
