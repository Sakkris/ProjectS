extends Node3D

@onready var time_label = $SubViewport/PlayerUIControl/TimeLabel
@onready var kill_label = $SubViewport/PlayerUIControl/KillLabel
@onready var player_speed_label = $SubViewport/PlayerUIControl/SpeedLabel
@onready var fps_counter = $SubViewport/PlayerUIControl/FPSCounter

var num_kills = 0
var player


func _ready():
	GameEvents.game_time_updated.connect(on_game_time_updated)
	GameEvents.enemy_died.connect(func(): update_kill_label())
	
	var viewport: SubViewport = $SubViewport
	viewport.set_clear_mode(SubViewport.CLEAR_MODE_ALWAYS)
	viewport.transparent_bg = true
	
	$ViewportQuad.material_override.albedo_texture = viewport.get_texture()
	$ViewportQuad.material_override.flags_transparent = true
	
	await owner.ready
	player = owner


func _process(_delta):
	fps_counter.set_text(str(Engine.get_frames_per_second()) + " fps")
	
	player_speed_label.set_text("%.2f m/s" % player.velocity.length())


func update_kill_label():
	num_kills += 1
	kill_label.set_text("%02d DESTROYED" % num_kills)


func on_game_time_updated(time_elapsed):
	var minute: int = time_elapsed / 60
	var second: int = time_elapsed - minute * 60
	
	time_label.set_text("%02d:%02d" % [minute, second])
#	print("%02d:%02d" % [minute, second])
