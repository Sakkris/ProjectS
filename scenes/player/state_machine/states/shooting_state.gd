extends MovingState

class_name ShootingState

var gun_controller


func _ready():
	gun_controller = get_tree().get_first_node_in_group("player").get_node("GunController")
	gun_controller.start_shooting(controller_id)
	print("Shooting state")


func trigger_released():
	gun_controller.stop_shooting(controller_id)
	change_state.call("armed")
