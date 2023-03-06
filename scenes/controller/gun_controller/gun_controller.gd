extends Node

class Gun:
	var is_shooting: bool = false
	var can_shoot: bool = true
	var magazine_size: int
	var current_bullets: int

@export var bullet_scene : PackedScene
@export var magazine_size : int = 30

var left_gun: Gun
var right_gun: Gun


func _ready():
	$LeftGunCooldown.timeout.connect(on_left_gun_cooldown_timeout)
	$RightGunCooldown.timeout.connect(on_right_gun_cooldown_timeout)
	
	left_gun = Gun.new()
	left_gun.magazine_size = magazine_size
	left_gun.current_bullets = magazine_size
	
	right_gun = Gun.new()
	right_gun.magazine_size = magazine_size
	right_gun.current_bullets = magazine_size


func _process(_delta):
	if left_gun.is_shooting && left_gun.can_shoot && left_gun.current_bullets != 0:
		left_gun.can_shoot = false
		$LeftGunCooldown.start()
		shoot_weapon(1)
	
	if right_gun.is_shooting && right_gun.can_shoot && right_gun.current_bullets != 0:
		right_gun.can_shoot = false
		$RightGunCooldown.start()
		shoot_weapon(2)


func shoot_weapon(controller_id):
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
	
	if controller_id == 1:
		left_gun.current_bullets -= 1
	
	if controller_id == 2:
		right_gun.current_bullets -= 1


func _on_controller_shooting_request(controller_id):
	if controller_id == 1:
		left_gun.is_shooting = true
	elif controller_id == 2:
		right_gun.is_shooting = true
	else:
		return
	
	shoot_weapon(controller_id)


func _on_controller_stop_shooting_request(controller_id):
	if controller_id == 1:
		left_gun.is_shooting = false
		left_gun.current_bullets = left_gun.magazine_size
	elif controller_id == 2:
		right_gun.is_shooting = false
		right_gun.current_bullets = right_gun.magazine_size


func on_left_gun_cooldown_timeout():
	left_gun.can_shoot = true


func on_right_gun_cooldown_timeout():
	right_gun.can_shoot = true
