extends MovingState
class_name ArmedState


func _ready():
	print("Armed State")


func thumbstick_pressed():
	PlayerEvents.emit_stop_thrusting_request(controller_id)
	PlayerEvents.emit_player_changed_state("unarmed")
	change_state.call("unarmed")


func trigger_pressed():
	change_state.call("shooting")


func by_button_pressed():
	PlayerEvents.emit_dash_request(controller_id)


func grip_pressed():
	PlayerEvents.emit_start_thrusting_request(controller_id)


func grip_released():
	PlayerEvents.emit_stop_thrusting_request(controller_id)
