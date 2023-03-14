extends Node
class_name Gun

@onready var shooting_cooldown_timer: Timer = $ShootingCooldownTimer
@onready var start_recharge_timer: Timer = $StartRechargeTimer
@onready var recharge_cooldown_timer: Timer = $RechargeCooldownTimer

@export var bullet_scene : PackedScene
@export var magazine_size : int = 15

var is_shooting: bool
var current_bullets: int
var passive_recharge_cooldown: float = .5
var fast_recharge_cooldown: float = 0.05
var nuzzle: Node3D


func _ready():
	shooting_cooldown_timer.timeout.connect(on_shooting_cooldown_timer_timeout)
	start_recharge_timer.timeout.connect(on_start_recharge_timer_timeout)
	recharge_cooldown_timer.timeout.connect(on_recharge_cooldown_timer_timeout)
	
	current_bullets = magazine_size


func shoot():
	recharge_cooldown_timer.stop()
	var bullet = bullet_scene.instantiate()
	
	get_tree().get_first_node_in_group("bullet_manager").add_child(bullet)
	bullet.global_transform = nuzzle.global_transform
	
	shooting_cooldown_timer.start()
	decrease_bullet_count()


func decrease_bullet_count():
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
	print(current_bullets, " / ", magazine_size)


func start_shooting():
	is_shooting = true
	shoot()


func stop_shooting():
	is_shooting = false
	start_recharge_timer.start()


func on_shooting_cooldown_timer_timeout():
	if is_shooting:
		shoot()


func on_start_recharge_timer_timeout():
	start_passive_recharge()


func on_recharge_cooldown_timer_timeout():
	recharge()
