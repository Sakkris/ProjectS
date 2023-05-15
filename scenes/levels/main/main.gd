class_name MainLevel
extends Node3D

## Request staging exit to main menu
##
## This signal is used to request the staging transition to the main-menu
## scene. Developers should use [method exit_to_main_menu] rather than
## emitting this signal directly.
signal request_exit_to_main_menu

## Request staging load a new scene
##
## This signal is used to request the staging transition to the specified
## scene. Developers should use [method load_scene] rather than emitting
## this signal directly.
signal request_load_scene(p_scene_path)

## Request staging reload the current scene
##
## This signal is used to request the staging reload this scene. Developers
## should use [method reset_scene] rather than emitting this signal directly.
signal request_reset_scene


## Environment
#
# Here we set the environment we need to set as our world environment
# once our scene is loaded.

@export var environment : Environment

func _ready():
	pass

func center_player_on(p_transform : Transform3D):
	# In order to center our player so the players feet are at the location
	# indicated by p_transform, and having our player looking in the required
	# direction, we must offset this transform using the cameras transform.

	# So we get our current camera transform in local space
	var camera_transform = $Player/XROrigin3D/XRCamera3D.transform

	# We obtain our view direction and zero out our height
	var view_direction = camera_transform.basis.z
	view_direction.y = 0

	# Now create the transform that we will use to offset our input with
	var new_transform : Transform3D
	new_transform = new_transform.looking_at(-view_direction, Vector3.UP)
	new_transform.origin = camera_transform.origin
	new_transform.origin.y = 0

	# And now update our origin point
	$Player/XROrigin3D.global_transform = (p_transform * new_transform.inverse()).orthonormalized()

func scene_loaded():
	# Called after scene is loaded

	# Make sure our camera becomes the current camera
	$Player/XROrigin3D/XRCamera3D.current = true
	$Player/XROrigin3D.current = true

	# Center our player on our origin point
	# Note, this means you can place the XROrigin3D point in the start
	# position where you want the player to spawn, even if the player is
	# physically halfway across the room.
	center_player_on($Player/XROrigin3D.global_transform)
	NavPointGenerator.generate_astar()

func scene_visible():
	GameEvents.emit_game_start()


func scene_pre_exiting():
	# Called before we start fading out and removing our scene
	pass


func scene_exiting():
	# called right before we remove this scene
	pass


## Transition to the main menu scene
##
## This function is used to transition to the main menu scene. The default
## implementation sends the [signal request_exit_to_main_menu].
##
## Custom scene classes can override this function to add their logic, but
## should usually call this super method.
func exit_to_main_menu() -> void:
	emit_signal("request_exit_to_main_menu")


## Transition to specific scene
##
## This function is used to transition to the specified scene. The default
## implementation sends the [signal request_load_scene].
##
## Custom scene classes can override this function to add their logic, but
## should usually call this super method.
func load_scene(p_scene_path : String) -> void:
	emit_signal("request_load_scene", p_scene_path)


## Reset current scene
##
## This function is used to reset the current scene. The default
## implementation sends the [signal request_reset_scene] which triggers
## a reload of the current scene.
##
## Custom scene classes can override this method to implement faster reset
## logic than is performed by the brute-force scene-reload performed by
## staging.
func reset_scene() -> void:
	emit_signal("request_reset_scene")


# Verifies our staging has a valid configuration.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	# Report missing environment
	if !environment:
		warnings.append("No environment specified")

	# Return warnings
	return warnings
