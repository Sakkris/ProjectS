extends Node3D

@export var gun_ability: Ability
@export var thruster_ability: Ability
@export var dash_ability: Ability

@onready var bullet_slider: ProgressBar = $%BulletProgressBar
@onready var thruster_slider: ProgressBar = $%ThrusterProgressBar
@onready var dash_slider: ProgressBar = $%DashProgressBar


func _ready():
	# Clear the viewport.
	var viewport = $SubViewport
	$SubViewport.set_clear_mode(SubViewport.CLEAR_MODE_ONCE)
	
	# Retrieve the texture and set it to the viewport quad.
	$ViewportQuad.material_override.albedo_texture = viewport.get_texture()


func _process(_delta):
	update_bullet_slider()
	update_thruster_slider()
	update_dash_slider()


func update_bullet_slider():
#	print("Should be updating values")
	bullet_slider.value = gun_ability.current_bullets
	bullet_slider.max_value = gun_ability.magazine_size


func update_thruster_slider():
	thruster_slider.value = thruster_ability.current_charge
	thruster_slider.max_value = thruster_ability.max_charge


func update_dash_slider():
	var cooldown_timer = dash_ability.cooldown_timer
	dash_slider.value = cooldown_timer.wait_time - cooldown_timer.time_left
	dash_slider.max_value = cooldown_timer.wait_time
