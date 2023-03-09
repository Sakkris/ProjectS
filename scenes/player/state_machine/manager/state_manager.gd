extends Node

class_name StateManager

@export_enum("Left:1", "Right:2") var controller

var current_state
var state_factory : StateFactory


func _ready():
	state_factory = StateFactory.new()
	change_state("unarmed")


func change_state(new_state_name):
	if current_state != null:
		current_state.queue_free()
	
	current_state = state_factory.get_state(new_state_name)
	current_state.setup(Callable(self, "change_state"), self, controller)
	current_state.name = "current_state"
	add_child(current_state)


func thumbstick_pressed():
	current_state.thumbstick_pressed()


func trigger_pressed():
	current_state.trigger_pressed()


func trigger_released():
	current_state.trigger_released()
