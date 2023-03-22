extends Node3D

@export_enum("Left:1", "Right:2") var controller_id

@onready var bullet_slider: ProgressBar = $%BulletProgressBar
@onready var thruster_slider: ProgressBar = $%ThrusterProgressBar
@onready var dash_slider: ProgressBar = $%DashProgressBar


func _ready():
	GameEvents.player_bullets_updated.connect(on_player_bullets_updated)
	GameEvents.player_thruster_updated.connect(on_player_thruster_updated)
	GameEvents.player_dash_updated.connect(on_player_dash_updated)
	
	# Clear the viewport.
	var viewport = $SubViewport
	$SubViewport.set_clear_mode(SubViewport.CLEAR_MODE_ONCE)
	
	# Retrieve the texture and set it to the viewport quad.
	$ViewportQuad.material_override.albedo_texture = viewport.get_texture()


func update_bullet_slider(current_bullets: int, magazine_size: int):
#	print("Should be updating values")
	bullet_slider.value = current_bullets
	bullet_slider.max_value = magazine_size


func update_thruster_slider(current_charge: float, max_charge: float):
	thruster_slider.value = current_charge
	thruster_slider.max_value = max_charge


func update_dash_slider(cooldown_left, cooldown):
	dash_slider.value = cooldown_left
	dash_slider.max_value = cooldown


func on_player_bullets_updated(signal_controller_id: int, current_bullets: int, magazine_size: int):
#	print("Got the signals - ", signal_controller_id)
	if signal_controller_id == controller_id:
		update_bullet_slider(current_bullets, magazine_size)


func on_player_thruster_updated(signal_controller_id: int, current_charge: float, max_charge: float):
	if signal_controller_id == controller_id:
		update_thruster_slider(current_charge, max_charge)


func on_player_dash_updated(signal_controller_id: int, cooldown_left, cooldown):
	if signal_controller_id == controller_id:
		update_dash_slider(cooldown_left, cooldown)
