extends XRController3D


# Called when the node enters the scene tree for the first time.
func _ready():
	button_pressed.connect(self._on_left_controller_button_pressed)
	button_released.connect(self._on_left_controller_button_released)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_left_controller_button_pressed(button: String) -> void:
	print ("Button pressed: " + button)
 
func _on_left_controller_button_released(button: String) -> void:
	print ("Button release: " + button)
