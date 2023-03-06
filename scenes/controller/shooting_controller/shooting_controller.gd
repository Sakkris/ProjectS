extends Node


@export var bullet_scene : PackedScene


func _on_controller_shooting_request(controller_id):
	print("was called")
	var bullet = bullet_scene.instantiate()
	var controllers = get_tree().get_nodes_in_group("controller")
	var gun_nuzzle : Node3D
	
	for controller in controllers:
		if controller.get_tracker_hand() == controller_id:
			gun_nuzzle = controller.get_node("GunNuzzle") as Node3D
			break
	
	if gun_nuzzle == null:
		return
	
	get_tree().get_first_node_in_group("bullet_manager").add_child(bullet)
	bullet.global_transform = gun_nuzzle.global_transform
