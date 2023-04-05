extends RayCast3D

var last_viewport_point = null
 
func _process(delta):
	var raycast_collider = get_collider()
	
	if raycast_collider:
		try_to_send_input(raycast_collider)


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
	
	if last_viewport_point && last_viewport_point != viewport_point:
		# Send mouse motion to the GUI.
		var event = InputEventMouseMotion.new()
		event.position = viewport_point
		event.relative = viewport_point - last_viewport_point;
		event.velocity = (viewport_point - last_viewport_point) / 16.0; #?? chose an arbitrary scale here for now
		event.global_position = viewport_point
		viewport.push_input(event)
		print("Global Position: ", global_collision_point, " | Local Position: ",local_colision_point, " | Event Position: ", event.position, " | Viewport Size: ", viewport.size)
		
	last_viewport_point = viewport_point

