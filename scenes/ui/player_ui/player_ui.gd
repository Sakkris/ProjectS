extends Node3D

@onready var time_label = $%TimeLabel

func _ready():
	GameEvents.game_time_updated.connect(on_game_time_updated)
	
	var viewport: SubViewport = $SubViewport
	viewport.set_clear_mode(SubViewport.CLEAR_MODE_ALWAYS)
	viewport.transparent_bg = true
	
	$ViewportQuad.material_override.albedo_texture = viewport.get_texture()
	$ViewportQuad.material_override.flags_transparent = true


func on_game_time_updated(time_elapsed):
	var minute: int = time_elapsed / 60
	var second: int = time_elapsed - minute * 60
	
	time_label.text = "%02d:%02d" % [minute, second]
#	print("%02d:%02d" % [minute, second])
