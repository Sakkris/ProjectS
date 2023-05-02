extends Node3D

var countdown = 5


func _process(_delta):
	countdown = countdown - 1
	
	if countdown == 0:
		visible = false
		set_process(false)
