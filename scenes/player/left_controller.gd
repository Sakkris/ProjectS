extends XRController3D


signal shooting_request(controller_id: int)
signal stop_shooting_request(controller_id: int)


func _ready():
	button_pressed.connect(self._on_left_controller_button_pressed)
	button_released.connect(self._on_left_controller_button_released)


func _on_left_controller_button_pressed(button: String) -> void:
	match(button):
		"trigger_click":
			# Emite o sinal de shooting request com valor 1 para indicar que é o comando esquerdo
			shooting_request.emit(1)
 

func _on_left_controller_button_released(button: String) -> void:
	match(button):
		"trigger_click":
			# Emite o sinal de shooting request com valor 1 para indicar que é o comando esquerdos
			stop_shooting_request.emit(1)
