extends Node

signal game_time_updated
signal enemy_died
signal enemy_spawned
signal game_start
signal game_over
signal objective_destroyed
signal objective_created
signal switch_music_request


func emit_game_time_updated(time_elapsed):
	game_time_updated.emit(time_elapsed)


func emit_enemy_died(enemy: Node):
	enemy_died.emit(enemy)


func emit_enemy_spawned(enemy):
	enemy_spawned.emit(enemy)


func emit_game_start():
	game_start.emit()


func emit_game_over():
	game_over.emit()


func emit_objective_destroyed():
	objective_destroyed.emit()


func emit_objective_created(objective):
	objective_created.emit(objective)


func emit_switch_music_request(new_music):
	switch_music_request.emit(new_music)
