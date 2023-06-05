extends Node
class_name MusicManager


@onready var loading_music = preload("res://resources/sounds/music/loading.ogg")
@onready var main_music = preload("res://resources/sounds/music/battle.ogg")
@onready var game_over_music = preload("res://resources/sounds/music/in-the-wreckage.ogg")
@onready var music_player: AudioStreamPlayer = $MusicPlayer

enum music_list {LOADING, MAIN, GAME_OVER}

var current_music


func _ready():
	GameEvents.switch_music_request.connect(switch_music)
	switch_music(music_list.LOADING)


func switch_music(music: music_list):
	if current_music == music:
		return
	
	match music:
		music_list.LOADING:
			play_music(loading_music)
			current_music = music_list.LOADING
		music_list.MAIN:
			play_music(main_music)
			current_music = music_list.MAIN
		music_list.GAME_OVER:
			play_music(game_over_music)
			current_music = music_list.GAME_OVER


func play_music(music):
	music_player.stream = music
	music_player.play()
