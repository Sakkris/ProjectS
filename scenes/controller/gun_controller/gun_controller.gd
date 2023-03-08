extends Node


class Gun:
	var is_shooting: bool = false
	var can_shoot: bool = true
	var magazine_size: int
	var current_bullets: int
	var passive_recharge: bool = true
	var fast_recharge: bool = true
	var can_recharge: bool = true
	var passive_recharge_cooldown: float = .5
	var fast_recharge_cooldown: float = 0.05
	var gun_cooldown_timer_node: Timer
	var start_recharge_timer_node: Timer
	var recharge_cooldown_timer_node: Timer


signal gun_shot(controller_id)

@export var bullet_scene : PackedScene
@export var magazine_size : int = 30

enum GUN {LEFT = 1, RIGHT = 2}

var left_gun: Gun
var right_gun: Gun
var gun_dict # Dicionário que guarda as duas armas


func _ready():
	$LeftGunCooldown.timeout.connect(on_left_gun_cooldown_timeout)
	$LeftGunStartRecharge.timeout.connect(on_left_gun_recharge_timeout)
	$LeftGunRechargeCooldown.timeout.connect(on_left_gun_recharge_cooldown_timeout)
	
	$RightGunCooldown.timeout.connect(on_right_gun_cooldown_timeout)
	$RightGunStartRecharge.timeout.connect(on_right_gun_recharge_timeout)
	$RightGunRechargeCooldown.timeout.connect(on_right_gun_recharge_cooldown_timeout)
	
	left_gun = Gun.new()
	left_gun.magazine_size = magazine_size
	left_gun.current_bullets = magazine_size
	left_gun.gun_cooldown_timer_node = $LeftGunCooldown
	left_gun.start_recharge_timer_node = $LeftGunStartRecharge
	left_gun.recharge_cooldown_timer_node = $LeftGunRechargeCooldown
	
	
	right_gun = Gun.new()
	right_gun.magazine_size = magazine_size
	right_gun.current_bullets = magazine_size
	right_gun.gun_cooldown_timer_node = $RightGunCooldown
	right_gun.start_recharge_timer_node = $RightGunStartRecharge
	right_gun.recharge_cooldown_timer_node = $RightGunRechargeCooldown
	
	gun_dict = {
		GUN.LEFT : left_gun,
		GUN.RIGHT : right_gun,
	}


func _process(_delta):
	for gun in gun_dict:
		if gun_dict[gun].is_shooting && gun_dict[gun].can_shoot && gun_dict[gun].current_bullets != 0:
			gun_dict[gun].can_shoot = false
			
			gun_dict[gun].gun_cooldown_timer_node.start()
			
			shoot_gun(gun)
		elif (gun_dict[gun].passive_recharge || gun_dict[gun].fast_recharge) && gun_dict[gun].can_recharge:
			recharge_gun(gun)


func shoot_gun(controller_id):
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
	
	decrease_bullet_count(controller_id)
	gun_shot.emit(controller_id)


func decrease_bullet_count(controller_id):
	if !gun_dict.has(controller_id):
		return
	
	gun_dict[controller_id].current_bullets -= 1
	
	if gun_dict[controller_id].current_bullets == 0:
		if !gun_dict[controller_id].gun_cooldown_timer_node.is_stopped():
			gun_dict[controller_id].gun_cooldown_timer_node.stop()
		
		start_fast_recharge(controller_id)


func recharge_gun(gun_id):
	if !gun_dict.has(gun_id):
		return
	
	if gun_dict[gun_id].current_bullets < gun_dict[gun_id].magazine_size:
		gun_dict[gun_id].current_bullets += 1
		gun_dict[gun_id].can_recharge = false
		
		var recharge_time
		
		if gun_dict[gun_id].passive_recharge:
			recharge_time = gun_dict[gun_id].passive_recharge_cooldown
			
		elif gun_dict[gun_id].fast_recharge:
			recharge_time = gun_dict[gun_id].fast_recharge_cooldown
		
		gun_dict[gun_id].recharge_cooldown_timer_node.wait_time = recharge_time
		gun_dict[gun_id].recharge_cooldown_timer_node.start() 
		
		#print("Gun0", gun_id, ": ", gun_dict[gun_id].current_bullets, "/", gun_dict[gun_id].magazine_size)
	else:
		gun_dict[gun_id].passive_recharge = false
		gun_dict[gun_id].fast_recharge = false
		gun_dict[gun_id].can_shoot = true


func stop_passive_recharge(gun_id):
	if !gun_dict.has(gun_id):
		return
	
	if !gun_dict[gun_id].start_recharge_timer_node.is_stopped():
		gun_dict[gun_id].start_recharge_timer_node.stop()
	
	gun_dict[gun_id].passive_recharge = false


func start_passive_recharge_timer(gun_id):
	if !gun_dict.has(gun_id):
		return
	
	if gun_dict[gun_id].start_recharge_timer_node.is_stopped():
		if gun_dict[gun_id].current_bullets != gun_dict[gun_id].magazine_size:
			gun_dict[gun_id].start_recharge_timer_node.start()


func start_passive_recharge(gun_id):
	if !gun_dict.has(gun_id):
		return
	
	if !gun_dict[gun_id].fast_recharge:
		gun_dict[gun_id].passive_recharge = true


func start_fast_recharge(gun_id):
	if !gun_dict.has(gun_id):
		return
	
	gun_dict[gun_id].can_shoot = false
	gun_dict[gun_id].fast_recharge = true


func _on_controller_shooting_request(controller_id):
	if !gun_dict.has(controller_id):
		return
	
	gun_dict[controller_id].is_shooting = true
	stop_passive_recharge(controller_id)


func _on_controller_stop_shooting_request(controller_id):
	if !gun_dict.has(controller_id):
		return
	
	gun_dict[controller_id].is_shooting = false
	start_passive_recharge_timer(controller_id)


func on_left_gun_cooldown_timeout():
	left_gun.can_shoot = true


func on_right_gun_cooldown_timeout():
	right_gun.can_shoot = true


func on_left_gun_recharge_timeout():
	start_passive_recharge(GUN.LEFT)


func on_right_gun_recharge_timeout():
	start_passive_recharge(GUN.RIGHT)


func on_left_gun_recharge_cooldown_timeout():
	left_gun.can_recharge = true


func on_right_gun_recharge_cooldown_timeout():
	right_gun.can_recharge = true
