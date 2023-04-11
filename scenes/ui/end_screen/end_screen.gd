extends Node3D


@onready var button: Button = $SubViewport/MarginContainer/Button


func _ready():
	var viewport: SubViewport = $SubViewport
	viewport.set_clear_mode(SubViewport.CLEAR_MODE_ALWAYS)
	viewport.transparent_bg = true
	
	$ViewportQuad.material_override.albedo_texture = viewport.get_texture()
	$ViewportQuad.material_override.flags_transparent = true
	
	button.button_down.connect(on_button_down)


func on_button_down():
	get_tree().paused = false
	get_tree().reload_current_scene()
