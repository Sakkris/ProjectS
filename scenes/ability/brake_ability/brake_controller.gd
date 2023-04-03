extends Ability

var is_braking: bool = false


func _physics_process(delta):
	if not is_braking:
		return
	
	velocity_component.decelerate(delta)


func use():
	is_braking = true


func stop():
	is_braking = false
