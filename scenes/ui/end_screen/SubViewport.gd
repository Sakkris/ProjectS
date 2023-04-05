extends SubViewport

var icon_scene = preload("res://tmp_icon.tscn")
var icon = null


#func _ready():
#	var ref_icon = icon_scene.instantiate()
#	add_child(ref_icon)
#	ref_icon.position = Vector2(size) / 2
#	print("Reference Icon: ", ref_icon.position)
#
#func _input(event):
#	if !icon:
#		icon = icon_scene.instantiate()
#		add_child(icon)
#
#	icon.position = event.position
