extends Ability

@onready var cooldown_timer: Timer = $DashCooldownTimer

@export var dash_force: float = 10

var can_dash: bool = true


func _ready():
	cooldown_timer.timeout.connect(on_cooldown_timer_timeout)


func use():
	if !can_dash:
		return
	
	var basis = gun_nuzzle.global_transform.basis
	velocity_component.reset_if_opposite_velocity(-basis.z)
	velocity_component.velocity += -basis.z * dash_force
	
	start_cooldown()


func reset():
	cooldown_timer.stop()
	can_dash = true


func start_cooldown():
	cooldown_timer.start()
	can_dash = false


func on_cooldown_timer_timeout():
	can_dash = true
