extends Node

signal start_shooting_request
signal stop_shooting_request
signal dash_request
signal start_braking_request
signal stop_braking_request
signal start_boosting_request
signal stop_boosting_request


func emit_start_shooting_request(controller_id: int):
	start_shooting_request.emit(controller_id)


func emit_stop_shooting_request(controller_id: int):
	stop_shooting_request.emit(controller_id)


func emit_dash_request(controller_id: int):
	dash_request.emit(controller_id)


func emit_start_braking_request(controller_id: int):
	start_braking_request.emit(controller_id)


func emit_stop_braking_request(controller_id: int):
	stop_braking_request.emit(controller_id)


func emit_start_boosting_request(controller_id: int):
	start_boosting_request.emit(controller_id)


func emit_stop_boosting_request(controller_id: int):
	stop_boosting_request.emit(controller_id)
