extends Node

signal gun_shot(controller_id)

@export var bullet_scene : PackedScene

@onready var left_gun: Gun = $LeftGun
@onready var right_gun: Gun = $RightGun

enum GUN {LEFT = 1, RIGHT = 2}

var gun_dict # Dicionário que guarda as duas armas


func _ready():
	GameEvents.start_shooting_request.connect(on_start_shooting_request)
	GameEvents.stop_shooting_request.connect(on_stop_shooting_request)
	
	gun_dict = {
		GUN.LEFT: left_gun,
		GUN.RIGHT: right_gun
	}


func set_nuzzles():
	var controllers = get_tree().get_nodes_in_group("controller")
	
	for controller in controllers:
#		print(controller, " - ", controller.get_tracker_hand())
		if controller.get_tracker_hand() == GUN.LEFT:
			left_gun.nuzzle = controller.get_node("GunNuzzle")
			left_gun.controller_id = GUN.LEFT
#			print("left gun: ", left_gun.nuzzle)
		elif controller.get_tracker_hand() == GUN.RIGHT:
			right_gun.nuzzle = controller.get_node("GunNuzzle")
			right_gun.controller_id = GUN.RIGHT
#			print("right gun: ", right_gun.nuzzle)


func on_start_shooting_request(gun_id):
	if gun_dict.has(gun_id):
		if gun_dict[gun_id].nuzzle == null:
			set_nuzzles()
		
		gun_dict[gun_id].start_shooting()


func on_stop_shooting_request(gun_id):
	if gun_dict.has(gun_id):
		gun_dict[gun_id].stop_shooting()
