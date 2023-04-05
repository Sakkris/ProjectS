extends Ability

var is_boosting: bool = false


func _physics_process(delta):
	if not is_boosting:
		return
	
	velocity_component.accelerate(delta)


func use():
	is_boosting = true


func stop():
	is_boosting = false
