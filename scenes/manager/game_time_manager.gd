extends Node

@onready var timer: Timer = $Timer

var elapsed_time: float = 0
var last_time = 0
var time_checkpoint_rechead = 0


func _ready():
	GameEvents.game_start.connect(func(): timer.start())
	GameEvents.objective_destroyed.connect(func(): add_time())
	timer.timeout.connect(on_timer_timeout)


func _process(_delta):
	if timer.is_stopped():
		pass
	
	elapsed_time = timer.wait_time * time_checkpoint_rechead + timer.wait_time - timer.time_left
	
	if last_time != int(elapsed_time):
		last_time = int(elapsed_time)
		
		GameEvents.emit_game_time_updated(timer.wait_time - elapsed_time)
#		GameEvents.emit_game_time_updated(elapsed_time)


func add_time():
	var new_time = timer.time_left + 5
	timer.wait_time = new_time
	timer.start()
	elapsed_time = 0


func finish_game():
	GameEvents.emit_game_over()


func on_timer_timeout():
	finish_game()
