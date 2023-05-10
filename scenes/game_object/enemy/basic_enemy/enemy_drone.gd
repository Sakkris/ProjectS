extends CharacterBody3D

@onready var velocity_component: VelocityComponent = $VelocityComponent

var player: Player = null
var path_to_follow: PackedVector3Array
var last_visited_point: Vector3


func _ready():
	$Hurtbox.area_entered.connect(self.on_hit_taken)


func _physics_process(delta):
	if !path_to_follow.is_empty():
		for next_point in path_to_follow:
			if next_point != last_visited_point:
				var direction = (next_point - global_position).normalized()
				velocity_component.accelerate_in_direction(direction, delta)
				velocity_component.move(delta)
				
				if next_point.distance_to(global_position) < .5:
					last_visited_point = next_point


func on_hit_taken(_area):
	GameEvents.emit_enemy_died()
	queue_free()
