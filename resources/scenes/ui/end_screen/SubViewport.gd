extends SubViewport

var icon_scene = preload("res://tmp_icon.tscn")
var icon = null


func _ready():
	$MarginContainer/Button.mouse_entered.connect(on_mouse_entered_button)

func _unhandled_input(event):	
	if !icon:
		icon = icon_scene.instantiate()
		add_child(icon)

	icon.position = event.position


func on_mouse_entered_button():
	print("Mouse inside button")
