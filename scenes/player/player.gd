extends Node3D
 

var webxr_interface
 

func _ready() -> void:
	$CanvasLayer.visible = false
	$CanvasLayer/Button.pressed.connect(self._on_button_pressed)
	
	webxr_interface = XRServer.find_interface("WebXR")
	if webxr_interface:
		webxr_interface.session_supported.connect(self._webxr_session_supported)
		webxr_interface.session_started.connect(self._webxr_session_started)
		webxr_interface.session_ended.connect(self._webxr_session_ended)
		webxr_interface.session_failed.connect(self._webxr_session_failed)
		
		webxr_interface.is_session_supported("immersive-vr")
 

func _webxr_session_supported(session_mode: String, supported: bool) -> void:
	if session_mode == 'immersive-vr':
		if supported:
			$CanvasLayer.visible = true
		else:
			OS.alert("Your browser doesn't support VR")
 

func _on_button_pressed() -> void:
	webxr_interface.session_mode = 'immersive-vr'
	webxr_interface.requested_reference_space_types = 'bounded-floor, local-floor, local'
	webxr_interface.required_features = 'local-floor'
	webxr_interface.optional_features = 'bounded-floor'
	
	if not webxr_interface.initialize():
		OS.alert("Failed to initialize WebXR")
		return
 

func _webxr_session_started() -> void:
	$CanvasLayer.visible = false
	
	get_viewport().use_xr = true
	
	print ("Reference space type: " + webxr_interface.reference_space_type)
 

func _webxr_session_ended() -> void:
	$CanvasLayer.visible = true
	
	get_viewport().use_xr = false
 

func _webxr_session_failed(message: String) -> void:
	OS.alert("Failed to initialize: " + message)
