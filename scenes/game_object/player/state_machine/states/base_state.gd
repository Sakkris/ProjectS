extends Node
class_name BaseState

var change_state
var persistent_state
var controller_id


func setup(_change_state, _persistent_state, _controller_id):
	self.change_state = _change_state
	self.persistent_state = _persistent_state
	self.controller_id = _controller_id


func thumbstick_pressed():
	pass


func trigger_pressed():
	pass


func trigger_released():
	pass


func grip_pressed():
	pass


func grip_released():
	pass


func ax_button_pressed():
	pass


func ax_button_released():
	pass


func by_button_pressed():
	pass


func by_button_released():
	pass
