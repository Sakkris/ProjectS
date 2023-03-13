extends Node

signal start_shooting_request
signal stop_shooting_request


func emit_start_shooting_request(controller_id: int):
	start_shooting_request.emit(controller_id)


func emit_stop_shooting_request(controller_id: int):
	stop_shooting_request.emit(controller_id)
