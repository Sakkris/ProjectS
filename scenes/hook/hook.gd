extends Node3D
class_name Hook

signal hook_finished_retracting

const HOOK_THROW_SPEED = 20.0
const HOOK_RETRACT_SPEED = 35.0

@export var hook_max_length: float = 15

@onready var hook_tip = $HookTip
@onready var hook_line_origin = $LineOrigin
@onready var hook_line = $%Line

var player_gun_nuzzle: Node3D

enum states {HOOKING, COLLIDING, RETRACTING}

var current_state
var last_length = 0


func _ready():
	hook_line_origin.scale.z = 0
	hook_line.visible = true


func _physics_process(delta):
	#$GunNuzzle.global_transform = player_gun_nuzzle.global_transform
	draw_line()
	
	
	match current_state:
		states.HOOKING:
			throw_hook(delta)
		states.COLLIDING:
			pass
		states.RETRACTING:
			retract_hook(delta)


func throw_hook(delta):
	if not are_numbers_close(hook_current_length(), hook_max_length):
		hook_tip.global_translate(transform.basis.z * -HOOK_THROW_SPEED * delta)
		
		if hook_current_length() > hook_max_length:
			var distance_overshot = hook_current_length() - hook_max_length
			#print("Distance: ", hook_current_length(), " / Overshot:", distance_overshot)
			
			hook_tip.global_translate(Vector3.BACK * distance_overshot)
			
			#print("New Distance: ", hook_current_length())
		
		last_length = hook_current_length()
	else:
		change_state(states.RETRACTING)


func retract_hook(delta):
	if last_length > 0:
		var direction = hook_tip.global_transform.origin.direction_to(player_gun_nuzzle.global_transform.origin)
		
		hook_tip.global_translate(direction * HOOK_RETRACT_SPEED * delta)
		
		last_length -= last_length - hook_current_length() 
		
		if are_numbers_close(last_length, 0):
			hook_tip.global_translate(Vector3.FORWARD * hook_current_length())
			last_length = 0
	else:
		hook_finished_retracting.emit()
		queue_free()


func draw_line():
	if hook_current_length() == 0:
		return
	
	hook_line_origin.global_transform = player_gun_nuzzle.global_transform
	#hook_line.global_translate(-hook_tip.global_transform.basis.z * hook_current_length() / 2)
	hook_line_origin.look_at(hook_tip.global_transform.origin, player_gun_nuzzle.global_transform.basis.y)
	hook_line_origin.scale.z = hook_current_length()
	


func change_state(new_state):
	current_state = new_state


func hook_current_length() -> float:
	return hook_tip.global_transform.origin.distance_to(player_gun_nuzzle.global_transform.origin)


func are_numbers_close(number1: float, number2: float) -> float:
	return number2 - 0.5 < number1 && number1 < number2 + 0.5
