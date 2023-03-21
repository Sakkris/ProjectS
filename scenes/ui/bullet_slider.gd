extends Node3D

@export_enum("Left:1", "Right:2") var controller_id

@onready var bullet_slider: ProgressBar = $%BulletProgressBar
@onready var thruster_slider: ProgressBar = $%ThrusterProgressBar
@onready var dash_slider: ProgressBar = $%DashProgressBar


func _ready():
	GameEvents.player_bullets_updated.connect(on_player_bullets_updated)
	
	# Clear the viewport.
	var viewport = $SubViewport
	$SubViewport.set_clear_mode(SubViewport.CLEAR_MODE_ONCE)
	
	# Retrieve the texture and set it to the viewport quad.
	$ViewportQuad.material_override.albedo_texture = viewport.get_texture()


func update_bullet_slider(current_bullets: int, magazine_size: int):
#	print("Should be updating values")
	bullet_slider.value = current_bullets
	bullet_slider.max_value = magazine_size


func on_player_bullets_updated(signal_controller_id: int, current_bullets: int, magazine_size: int):
#	print("Got the signals - ", signal_controller_id)
	if signal_controller_id == controller_id:
		update_bullet_slider(current_bullets, magazine_size)
