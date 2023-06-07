extends Ability
class_name Gun

@export var magazine_size : int = 3
@export var knockback_force: float = .5 
@export var bullet_scene : PackedScene 
@export var shooting_audio: AudioStreamPlayer3D
@export var recharge_audio: AudioStreamPlayer3D

@onready var shooting_cooldown_timer: Timer = $ShootingCooldownTimer
@onready var start_recharge_timer: Timer = $StartRechargeTimer
@onready var recharge_cooldown_timer: Timer = $RechargeCooldownTimer

var is_shooting: bool
var current_bullets: int
var passive_recharge_cooldown: float = .8
var fast_recharge_cooldown: float = .5


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
	bullet.global_transform = gun_nuzzle.global_transform
	get_tree().get_first_node_in_group("projectile_manager").add_child(bullet)
	
	if shooting_audio:
		shooting_audio.play()
	
	shooting_cooldown_timer.start()
	decrease_bullet_count()
	knockback_player()


func knockback_player():
	velocity_component.accelerate_in_direction(gun_nuzzle.global_transform.basis.z * knockback_force, 1)


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
	
	if current_bullets == magazine_size:
		if recharge_audio:
			recharge_audio.play()
		return
	recharge_cooldown_timer.start()


func use():
	is_shooting = true
	shoot()


func stop():
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
