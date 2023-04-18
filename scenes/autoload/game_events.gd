extends Node

signal game_time_updated
signal enemy_died
signal enemy_spawned
signal game_start
signal game_over


func emit_game_time_updated(time_elapsed):
	game_time_updated.emit(time_elapsed)


func emit_enemy_died():
	enemy_died.emit()


func emit_enemy_spawned(enemy):
	enemy_spawned.emit(enemy)


func emit_game_start():
	game_start.emit()


func emit_game_over():
	game_over.emit()
