extends ControllerState
class_name PausedState


@export var raycast_mesh: MeshInstance3D 
@export var raycast: RayCast3D

var player_velocity_component: VelocityComponent


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func enter(_msg := {}) -> void:
	var player = controller.owner
	player_velocity_component = player.get_node("VelocityComponent")
	player_velocity_component.can_move = false
	
	raycast.enabled = true
	raycast_mesh.visible = true
	
	$"../../AimSight".disable_sight()


func exit() -> void:
	player_velocity_component.can_move = true
	raycast.enabled = false
	raycast_mesh.visible = false
