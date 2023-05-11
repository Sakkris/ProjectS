extends CharacterBody3D

@onready var velocity_component: VelocityComponent = $VelocityComponent

var player: Player = null
var path_to_follow: PackedVector3Array
var target_point: Vector3 = Vector3.INF


func _ready():
	$Hurtbox.area_entered.connect(self.on_hit_taken)


func _physics_process(delta):
	if target_point != Vector3.INF:
		var dir_to_target = global_transform.origin.direction_to(target_point).normalized()
		
		velocity_component.accelerate_in_direction(dir_to_target, delta)
		
		if global_transform.origin.distance_to(target_point) < 0.5:
			next_target_point()
	else:
		velocity_component.decelerate(delta)
	
	velocity_component.move(delta)


func next_target_point():
	if path_to_follow.size() > 1:
		target_point = path_to_follow[1]
	else:
		target_point = Vector3.INF


func on_hit_taken(_area):
	GameEvents.emit_enemy_died()
	queue_free()
