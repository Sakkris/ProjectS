extends Node
class_name Pair


var first_item = null
var second_item = null


func _init(first, second):
	first_item = first
	second_item = second


func set_first(item):
	first_item = item


func set_second(item):
	second_item = item


func get_first():
	return first_item


func get_second():
	return second_item
