class_name StateMachine
extends Node

signal transitioned(controller_id, state_name)

@export var initial_state := NodePath()

@onready var state: State = get_node(initial_state)
@onready var ability_manager = $"../AbilityManager"
@onready var change_state_audio = $"../ChangeStateAudio"


func _ready() -> void:
	await owner.ready
	
	for child in get_children():
		if child is State:
			child.state_machine = self
			child.ability_manager = ability_manager
	
	state.enter()


func _process(delta: float) -> void:
	state.update(delta)


func _physics_process(delta: float) -> void:
	state.physics_update(delta)


func transition_to(target_state_name: String, msg: Dictionary = {}) -> void:
	if not has_node(target_state_name):
		return

	state.exit()
	state = get_node(target_state_name)
	state.enter(msg)
	transitioned.emit(owner.get_tracker_hand(), state.name)


func handle_input_pressed(button: String):
	if state.has_method("handle_input_pressed"):
		state.handle_input_pressed(button)


func handle_input_released(button: String):
	if state.has_method("handle_input_released"):
		state.handle_input_released(button)
