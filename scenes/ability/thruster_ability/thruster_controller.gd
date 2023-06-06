extends Ability

@onready var start_recharge_timer = $StartRechargeTimer

@export var thruster_force: float = 1
@export var max_charge: float = 100
@export var discharge_rate: float = 20 
@export var recharge_rate: float = 30
@export var thruster_sound: AudioStreamPlayer3D 
@export var error_sound :AudioStreamPlayer3D

var current_charge 
var is_thrusting: bool = false
var is_charging: bool = false


func _ready():
	start_recharge_timer.timeout.connect(func(): is_charging = true)
	
	current_charge = max_charge


func _physics_process(delta):
	if is_thrusting:
		thrust(delta)
	elif is_charging:
		recharge(delta)


func thrust(delta):
	if gun_nuzzle == null:
		return
	
	if is_zero_approx(current_charge):
		thruster_sound.stop()
		return
	
	var basis = gun_nuzzle.global_transform.basis
	
	velocity_component.accelerate_in_direction(-basis.z * thruster_force, delta)
	current_charge = max(current_charge - discharge_rate * delta, 0)


func recharge(delta):
	if is_equal_approx(current_charge, max_charge):
		is_charging = false
		return
	
	current_charge = min(current_charge + recharge_rate * delta, max_charge)


func use():
	is_thrusting = true
	is_charging = false
	if is_zero_approx(current_charge):
		error_sound.play()
	else:
		thruster_sound.play()
	start_recharge_timer.stop()


func stop():
	is_thrusting = false
	thruster_sound.stop()
	start_recharge_timer.start()
