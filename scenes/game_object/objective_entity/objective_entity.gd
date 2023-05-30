extends Node3D

@onready var hurtbox: Area3D = $Hurtbox


func _ready():
	hurtbox.area_entered.connect(on_area_entered)


func destroy():
	GameEvents.emit_objective_destroyed()
	queue_free()


func on_area_entered(_other_area):
	destroy()
