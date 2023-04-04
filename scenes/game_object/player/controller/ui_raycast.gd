extends RayCast3D

 
func _process(delta):
	var raycast_collider = get_collider()
	
	if raycast_collider:
		try_to_send_input(raycast_collider)


func try_to_send_input(raycast_collider):
	var viewport = raycast_collider.get_child(0)
	if not (viewport is SubViewport):
		return # This isn't something we can give input to.

	var collider_transform = raycast_collider.global_transform
	if (collider_transform * global_transform.origin).z > 0:
		return # Don't allow pressing if we're behind the GUI.

	# Convert the collision to a relative position. Expects the 2nd child to be a CollisionShape.
	var shape_size = raycast_collider.get_child(1).shape.extents * 2
	var collision_point = get_collision_point()
	var collider_scale = collider_transform.basis.get_scale()
	var local_point = collider_transform * collision_point
	local_point /= (collider_scale * collider_scale)
	local_point /= shape_size
	local_point += Vector3(0.5, -0.5, 0) # X is about 0 to 1, Y is about 0 to -1.

	# Find the viewport position by scaling the relative position by the viewport size. Discard Z.
	var viewport_point = Vector2i(local_point.x, -local_point.y) * viewport.size

	# Send mouse motion to the GUI.
	var event = InputEventMouseMotion.new()
	event.position = viewport_point
	viewport.push_input(event)
