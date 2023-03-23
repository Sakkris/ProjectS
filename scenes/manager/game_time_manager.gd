extends Node

@onready var timer: Timer = $Timer

var elapsed_time: float = 0
var last_time = 0
var time_checkpoint_rechead = 0


func _ready():
	timer.timeout.connect(on_timer_timeout)


func _process(delta):
	elapsed_time = timer.wait_time * time_checkpoint_rechead + timer.wait_time - timer.time_left
	
	if last_time != int(elapsed_time):
		last_time = int(elapsed_time)
		GameEvents.emit_game_time_updated(elapsed_time)


func on_timer_timeout():
	time_checkpoint_rechead += 1
	timer.start()
