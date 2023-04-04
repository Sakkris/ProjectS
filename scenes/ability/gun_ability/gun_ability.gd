extends Node
class_name Gun

@onready var shooting_cooldown_timer: Timer = $ShootingCooldownTimer
@onready var start_recharge_timer: Timer = $StartRechargeTimer
@onready var recharge_cooldown_timer: Timer = $RechargeCooldownTimer

@export var bullet_scene : PackedScene
@export var magazine_size : int = 6

var is_shooting: bool
var current_bullets: int
var passive_recharge_cooldown: float = .6
var fast_recharge_cooldown: float = .3
var nuzzle: Node3D


func _ready():
	shooting_cooldown_timer.timeout.connect(on_shooting_cooldown_timer_timeout)
	start_recharge_timer.timeout.connect(on_start_recharge_timer_timeout)
	recharge_cooldown_timer.timeout.connect(on_recharge_cooldown_timer_timeout)
	
	current_bullets = magazine_size


func shoot():
	if current_bullets == 0:
		return
	
	recharge_cooldown_timer.stop()
	var bullet = bullet_scene.instantiate()
	
	get_tree().get_first_node_in_group("projectile_manager").add_child(bullet)
	bullet.global_transform = nuzzle.global_transform
	
	shooting_cooldown_timer.start()
	decrease_bullet_count()


func decrease_bullet_count():
	if current_bullets > 0:
		current_bullets -= 1
	
	if current_bullets == 0: 
		start_fast_recharge()


func start_passive_recharge():
	recharge_cooldown_timer.wait_time = passive_recharge_cooldown
	recharge_cooldown_timer.start()


func start_fast_recharge():
	shooting_cooldown_timer.stop()
	
	recharge_cooldown_timer.wait_time = fast_recharge_cooldown
	recharge_cooldown_timer.start()


func recharge():
	if current_bullets == magazine_size:
		recharge_cooldown_timer.stop()
		if is_shooting:
			shoot()
		
		return
	
	current_bullets += 1
	recharge_cooldown_timer.start()


func start_shooting():
	is_shooting = true
	shoot()


func stop_shooting():
	is_shooting = false
	start_recharge_timer.start()


func reset():
	recharge_cooldown_timer.stop()
	shooting_cooldown_timer.stop()
	start_recharge_timer.stop()
	
	current_bullets = magazine_size
	is_shooting = false


func on_shooting_cooldown_timer_timeout():
	if is_shooting:
		shoot()


func on_start_recharge_timer_timeout():
	start_passive_recharge()


func on_recharge_cooldown_timer_timeout():
	recharge()
