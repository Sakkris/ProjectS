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
		
		webxr_interface.select.connect(self._webxr_on_select)
		webxr_interface.selectstart.connect(self._webxr_on_select_start)
		webxr_interface.selectend.connect(self._webxr_on_select_end)
		
		webxr_interface.squeeze.connect(self._webxr_on_squeeze)
		webxr_interface.squeezestart.connect(self._webxr_on_squeeze_start)
		webxr_interface.squeezeend.connect(self._webxr_on_squeeze_end)
		
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
 
func _process(_delta: float) -> void:
	var thumbstick_vector: Vector2 = $XROrigin3D/LeftController.get_vector2("thumbstick")
	if thumbstick_vector != Vector2.ZERO:
		print ("Left thumbstick position: " + str(thumbstick_vector))
 
func _webxr_on_select(input_source_id: int) -> void:
	print("Select: " + str(input_source_id))
 
	var tracker: XRPositionalTracker = webxr_interface.get_input_source_tracker(input_source_id)
	var xform = tracker.get_pose('default').transform
	print (xform.origin)
 
func _webxr_on_select_start(input_source_id: int) -> void:
	print("Select Start: " + str(input_source_id))
 
func _webxr_on_select_end(input_source_id: int) -> void:
	print("Select End: " + str(input_source_id))
 
func _webxr_on_squeeze(input_source_id: int) -> void:
	print("Squeeze: " + str(input_source_id))
 
func _webxr_on_squeeze_start(input_source_id: int) -> void:
	print("Squeeze Start: " + str(input_source_id))
 
func _webxr_on_squeeze_end(input_source_id: int) -> void:
	print("Squeeze End: " + str(input_source_id))
