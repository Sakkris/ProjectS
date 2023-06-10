extends Node3D
class_name NavigationPoint

@export var id: int = 0

@export var connection_1: NavigationPoint = null
@export var connection_2: NavigationPoint = null
@export var connection_3: NavigationPoint = null

var connections: Array[NavigationPoint]

func _ready():
	# Work around por causa de bug no Godot 4.0 a exportar arrays 
	set_up_array()


func set_up_array():
	if connection_1:
		connections.append(connection_1)
	
	if connection_2:
		connections.append(connection_2)
	
	if connection_3:
		connections.append(connection_3)
