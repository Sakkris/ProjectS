extends Node3D

@onready var collection_audio: AudioStreamPlayer = $CollectedAudio
@onready var hurtbox: Area3D = $Hurtbox

var is_dead = false

func _ready():
	hurtbox.area_entered.connect(on_area_entered)


func destroy():
	if is_dead:
		return
	
	is_dead = true
	
	if collection_audio:
		visible = false
		collection_audio.play()
		await collection_audio.finished
	
	GameEvents.emit_objective_destroyed()
	queue_free()


func on_area_entered(_other_area):
	destroy()
