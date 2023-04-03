extends Ability

const VELOCITY_PENALTY = .2

@export var grab_area : Area3D

@onready var _averager := XRToolsVelocityAveragerLinear.new(5)
@onready var perserve_velocity_timer = $PerserveVelocityTimer

# Used Nodes References
var grab_area_collision: CollisionShape3D

# Used Variables
var is_grabbing = false
var grab_position: Vector3
var previous_velocity: Vector3


func _ready():
	# Connect to the GrabArea
	grab_area.body_entered.connect(on_body_entered)
	grab_area.area_entered.connect(on_area_entered)
	
	# Assign the collision shape
	grab_area_collision = grab_area.get_child(0)


func _physics_process(delta):
	# Check if grabbing something
	if not is_grabbing:
		return
	
	# Initialize the offset movement and current position
	var offset_movement = Vector3.ZERO
	var current_position = gun_nuzzle.global_transform.origin
	
	# Calculate the offset movement
	offset_movement =  grab_position - current_position
	
	# Apply the offset movement to the player
	velocity_component.full_stop()
	velocity_component.fixed_movement(offset_movement)
	
	# Save this movement to the avarager 
	_averager.add_distance(delta, offset_movement)
	
	# Return true to not be affected by gravity (might be redundant)
	return true


func start_grab():
	# Get the Grab Position and start grabbing
	grab_position = gun_nuzzle.global_transform.origin
	is_grabbing = true
	
	# Save the Current Player's Velocity and start the Timer
	perserve_velocity_timer.start()
	previous_velocity = velocity_component.velocity
	
	# Clear the _avarager distances and disable the default player movement
	_averager.clear()
	velocity_component.can_move = false


func use():
	grab_area_collision.disabled = false


func stop():
	# If player didn't grab anything no need to do anything other than disable the CollisionShape
	if !is_grabbing:
		grab_area_collision.disabled = true
		return
	
	# Disable the CollisionShape and stop grabbing 
	grab_area_collision.disabled = true
	is_grabbing = false
	
	if !perserve_velocity_timer.is_stopped():
		var new_direction = _averager.velocity().normalized()
		var velocity_penalty = previous_velocity.length() * VELOCITY_PENALTY
		
		velocity_component.velocity = new_direction * (previous_velocity.length() - velocity_penalty)
	else:
		# Make the player velocity the avarage velocity form the _avarager 
		velocity_component.velocity = _averager.velocity()
	
	velocity_component.can_move = true


func on_body_entered(_other_body):
	start_grab()


func on_area_entered(_other_area):
	start_grab()
