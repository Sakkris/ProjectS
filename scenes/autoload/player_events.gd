extends Node

signal start_shooting_request
signal stop_shooting_request
signal dash_request
signal start_braking_request
signal stop_braking_request
signal start_boosting_request
signal stop_boosting_request
signal start_thrusting_request
signal stop_thrusting_request
signal start_hooking_request
signal stop_hooking_request
signal hook_finished_retracting
signal start_grabbing_request
signal stop_grabbing_request
signal player_changed_state
signal player_bullets_updated
signal player_thruster_updated
signal player_dash_updated


func emit_player_changed_state(new_state: String):
	player_changed_state.emit(new_state)


func emit_start_shooting_request(controller_id: int):
	start_shooting_request.emit(controller_id)


func emit_stop_shooting_request(controller_id: int):
	stop_shooting_request.emit(controller_id)


func emit_dash_request(controller_id: int):
	dash_request.emit(controller_id)


func emit_start_braking_request():
	start_braking_request.emit()


func emit_stop_braking_request():
	stop_braking_request.emit()


func emit_start_boosting_request():
	start_boosting_request.emit()


func emit_stop_boosting_request():
	stop_boosting_request.emit()


func emit_start_thrusting_request(controller_id: int):
	start_thrusting_request.emit(controller_id)


func emit_stop_thrusting_request(controller_id: int):
	stop_thrusting_request.emit(controller_id)


func emit_start_hooking_request(controller_id: int):
	start_hooking_request.emit(controller_id)


func emit_stop_hooking_request(controller_id: int):
	stop_hooking_request.emit(controller_id)


func emit_hook_finished_retracting(controller_id: int):
	hook_finished_retracting.emit(controller_id)


func emit_start_grabbing_request(controller_id: int):
	start_grabbing_request.emit(controller_id)


func emit_stop_grabbing_request(controller_id: int):
	stop_grabbing_request.emit(controller_id)


func emit_player_bullets_updated(controller_id: int, current_bullets: int, magazine_size: int):
	player_bullets_updated.emit(controller_id, current_bullets, magazine_size)


func emit_player_thruster_updated(controller_id: int, current_charge: float, maximum_charge: float):
	player_thruster_updated.emit(controller_id, current_charge, maximum_charge)


func emit_player_dash_updated(controller_id: int, cooldown_left, cooldown):
	player_dash_updated.emit(controller_id, cooldown_left, cooldown)
