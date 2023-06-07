extends Node

@onready var canvas_layer = $CanvasLayer
@onready var start_button = $CanvasLayer/ColorRect/MarginContainer/Container/VBoxContainer/StartButton


func _ready():
	canvas_layer.visible = false
	start_button.pressed.connect(self._on_start_button_pressed)
	
	if GameProperties.webxr_interface:
		pass
	
	GameProperties.webxr_interface = XRServer.find_interface("WebXR")
	if GameProperties.webxr_interface:
		GameProperties.webxr_interface.session_supported.connect(self._webxr_session_supported)
		GameProperties.webxr_interface.session_started.connect(self._webxr_session_started)
		GameProperties.webxr_interface.session_ended.connect(self._webxr_session_ended)
		GameProperties.webxr_interface.session_failed.connect(self._webxr_session_failed)
		
		GameProperties.webxr_interface.is_session_supported("immersive-vr")


func _webxr_session_supported(session_mode: String, supported: bool) -> void:
	if session_mode == 'immersive-vr':
		if supported:
			canvas_layer.visible = true
		else:
			OS.alert("Your browser doesn't support VR")


func _on_start_button_pressed() -> void:
	GameProperties.webxr_interface.session_mode = 'immersive-vr'
	GameProperties.webxr_interface.requested_reference_space_types = 'bounded-floor, local-floor, local'
	GameProperties.webxr_interface.required_features = 'local-floor'
	GameProperties.webxr_interface.optional_features = 'bounded-floor'
	
	if not GameProperties.webxr_interface.initialize():
		OS.alert("Failed to initialize WebXR")
		return
 

func _webxr_session_started() -> void:
	canvas_layer.visible = false
	
	get_viewport().use_xr = true
	
	print ("Reference space type: " + GameProperties.webxr_interface.reference_space_type)


func _webxr_session_ended() -> void:
	canvas_layer.visible = true
	
	get_viewport().use_xr = false
 

func _webxr_session_failed(message: String) -> void:
	OS.alert("Failed to initialize: " + message)
