extends Node3D


func _ready():
	var viewport: SubViewport = $SubViewport
	viewport.set_clear_mode(SubViewport.CLEAR_MODE_ALWAYS)
	viewport.transparent_bg = true
	
	$ViewportQuad.material_override.albedo_texture = viewport.get_texture()
	$ViewportQuad.material_override.flags_transparent = true
	
	print("End Screen Local Position: ", position)
