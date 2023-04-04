extends Node

@export var end_screen: PackedScene

@onready var time_manager = $"../GameTimeManager"
@onready var player: CharacterBody3D = $"../Player"


func _ready():
	GameEvents.game_start.connect(on_game_start)
	GameEvents.game_over.connect(on_game_over)


func finish_game():
	var end_screen_instance = end_screen.instantiate() as Node3D
	add_child(end_screen_instance)
	
	end_screen_instance.global_position = player.global_position
	end_screen_instance.global_transform = player.global_transform
	end_screen_instance.global_translate(end_screen_instance.transform.basis.z * -2.0)
	end_screen_instance.global_translate(end_screen_instance.transform.basis.y * 1.5)
	
	player.velocity_component.full_stop()



func on_game_start():
	time_manager.timer.start()


func on_game_over():
	finish_game()
