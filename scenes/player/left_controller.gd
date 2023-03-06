extends XRController3D


signal shooting_request(controller: int)


func _ready():
	button_pressed.connect(self._on_left_controller_button_pressed)
	button_released.connect(self._on_left_controller_button_released)


func _on_left_controller_button_pressed(button: String) -> void:
	match(button):
		"trigger_click":
			# Emite um sinal com o valor "1" que é equivalente ao comandos esquerdo
			shooting_request.emit(1)
 

func _on_left_controller_button_released(button: String) -> void:
	print ("Button release: " + button)
