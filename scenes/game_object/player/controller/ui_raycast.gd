extends RayCast3D

var pointer_scene = preload("res://scenes/ui/misc/pointer.tscn")
var pointer_instance = null

var last_viewport_point = null
var controller: XRController3D = null 


func _ready():
	controller = owner


func _process(_delta):
	var raycast_collider = get_collider()
	
	if raycast_collider:
		try_to_send_input(raycast_collider)
	elif pointer_instance:
		pointer_instance.queue_free()
		pointer_instance = null


func try_to_send_input(raycast_collider):
	var viewport = raycast_collider.get_child(0)
	if not (viewport is SubViewport):
		return # This isn't something we can give input to.
	
	var global_collision_point = get_collision_point()
	var local_colision_point = raycast_collider.get_child(1).to_local(global_collision_point);
	var viewport_point = Vector2(local_colision_point.x, -local_colision_point.y)
	viewport_point = viewport_point + Vector2(0.5, 0.5)
	viewport_point.x *= viewport.size.x
	viewport_point.y *= viewport.size.y
	
	if controller.is_button_pressed("trigger_click"):
		var event = InputEventMouseButton.new()
		event.pressed = true
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = viewport_point
		event.global_position = viewport_point
		viewport.push_input(event)
	elif last_viewport_point && last_viewport_point != viewport_point:
		# Send mouse motion to the GUI.
		var event = InputEventMouseMotion.new()
		event.position = viewport_point
		event.relative = viewport_point - last_viewport_point;
		event.velocity = (viewport_point - last_viewport_point) / 16.0; #?? chose an arbitrary scale here for now
		event.global_position = viewport_point
		viewport.push_input(event)
	
	draw_pointer(viewport, viewport_point)
	last_viewport_point = viewport_point


func draw_pointer(viewport, vieport_point):
	if pointer_instance == null:
		pointer_instance = pointer_scene.instantiate()
		viewport.add_child(pointer_instance)
	
	pointer_instance.position = vieport_point

