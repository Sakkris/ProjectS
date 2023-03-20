extends Node

const VELOCITY_PENALTY = .2

@onready var _averager := XRToolsVelocityAveragerLinear.new(5)
@onready var perserve_velocity_timer = $PerserveVelocityTimer

# Used Nodes References
var player: CharacterBody3D
var player_velocity_component: VelocityComponent
var grab_area: Area3D
var grab_area_collision: CollisionShape3D
var controller: XRController3D

# Used Variables
var controller_id
var is_grabbing = false
var grab_position: Vector3
var previous_velocity: Vector3


func _ready():
	# Connect to GameEvents 
	GameEvents.start_grabbing_request.connect(on_start_grabbing_request)
	GameEvents.stop_grabbing_request.connect(on_stop_grabbing_request)
	
	# Get Controller Id and Controller Node
	controller_id = get_parent().controller_id
	controller = get_parent().get_parent() as XRController3D
	
	# Get the GrabArea Node and its CollisionShape 
	grab_area = controller.get_node("GrabArea") as Area3D
	grab_area_collision = grab_area.get_node("CollisionShape3D") as CollisionShape3D
	
	# Connect to the GrabArea
	grab_area.body_entered.connect(on_body_entered)
	
	# Get the Player Node and its VelocityComponent 
	player = get_tree().get_first_node_in_group("player") as CharacterBody3D
	player_velocity_component = player.get_node("VelocityComponent") as VelocityComponent


func _physics_process(delta):
	# Check if grabbing something
	if not is_grabbing:
		return
	
	# Initialize the offset movement and current position
	var offset_movement = Vector3.ZERO
	var current_position = controller.global_transform.origin
	
	# Calculate the offset movement
	offset_movement =  grab_position - current_position
	
	# Apply the offset movement to the player
	player_velocity_component.full_stop()
	player.move_and_collide(offset_movement)
	
	# Save this movement to the avarager 
	_averager.add_distance(delta, offset_movement)
	
	# Return true to not be affected by gravity (might be redundant)
	return true


func on_start_grabbing_request(signal_controller_id: int):
	# Check if the signal corresponds to this controller
	if controller_id == signal_controller_id:
		# Enable the CollisionShape of this controller
		grab_area_collision.disabled = false


func on_stop_grabbing_request(signal_controller_id: int):
	# Check if the signal corresponds to this controller
	if controller_id == signal_controller_id:
		# Disable the CollisionShape and stop grabbing 
		grab_area_collision.disabled = true
		is_grabbing = false
		
		if !perserve_velocity_timer.is_stopped():
			var new_direction = _averager.velocity().normalized()
			var velocity_penalty = previous_velocity.length() * VELOCITY_PENALTY
			
			player_velocity_component.velocity = new_direction * (previous_velocity.length() - velocity_penalty)
		else:
			# Make the player velocity the avarage velocity form the _avarager 
			player_velocity_component.velocity = _averager.velocity()
		
		
		player_velocity_component.can_move = true


func on_body_entered(other_body):
	# Get the Grab Position and start grabbing
	grab_position = controller.global_transform.origin
	is_grabbing = true
	
	# Save the Current Player's Velocity and start the Timer
	perserve_velocity_timer.start()
	previous_velocity = player_velocity_component.velocity
	
	# Clear the _avarager distances and disable the default player movement
	_averager.clear()
	player_velocity_component.can_move = false
