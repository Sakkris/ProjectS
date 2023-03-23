extends Node

signal game_time_updated


func emit_game_time_updated(time_elapsed):
	game_time_updated.emit(time_elapsed)
