extends Node3D

@onready var time_label = $SubViewport/PlayerUIControl/TimeLabel
@onready var kill_label = $SubViewport/PlayerUIControl/KillLabel
@onready var fps_counter = $SubViewport/PlayerUIControl/FPSCounter
@onready var height_label = $SubViewport/PlayerUIControl/Height
@onready var origin_label = $SubViewport/PlayerUIControl/Origin

var num_kills = 0

var height = 0
var origin = 0


func _ready():
	GameEvents.game_time_updated.connect(on_game_time_updated)
	GameEvents.enemy_died.connect(func(): update_kill_label())
	
	var viewport: SubViewport = $SubViewport
	viewport.set_clear_mode(SubViewport.CLEAR_MODE_ALWAYS)
	viewport.transparent_bg = true
	
	$ViewportQuad.material_override.albedo_texture = viewport.get_texture()
	$ViewportQuad.material_override.flags_transparent = true


func _process(_delta):
	fps_counter.set_text(str(Engine.get_frames_per_second()) + " fps")
	
	height_label.set_text("%.2f m" % height)
	origin_label.set_text("Origin: %.2f m" % origin)


func update_kill_label():
	num_kills += 1
	kill_label.set_text("%02d DESTROYED" % num_kills)


func on_game_time_updated(time_elapsed):
	var minute: int = time_elapsed / 60
	var second: int = time_elapsed - minute * 60
	
	time_label.set_text("%02d:%02d" % [minute, second])
#	print("%02d:%02d" % [minute, second])
