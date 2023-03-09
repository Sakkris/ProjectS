extends Node3D

class_name BaseState

var change_state
var persistent_state
var controller_id


func setup(change_state, persistent_state, controller_id):
	self.change_state = change_state
	self.persistent_state = persistent_state
	self.controller_id = controller_id


func thumbstick_pressed():
	pass


func trigger_pressed():
	pass


func trigger_released():
	pass
