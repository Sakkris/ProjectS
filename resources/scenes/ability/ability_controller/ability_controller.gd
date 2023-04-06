extends Node
class_name AbilityManager

@export var velocity_component: VelocityComponent

@onready var gun_nuzzle = $"../GunNuzzle"

var abilities = {}


func _ready() -> void:
	await owner.ready
	
	for child in get_children():
		child.velocity_component = velocity_component
		child.gun_nuzzle = gun_nuzzle
		
		abilities[child.name] = child


func use_ability(ability_name: String):
	ability_name = complete_ability_name(ability_name)
	
	await abilities[ability_name].use()


func stop_ability(ability_name: String):
	ability_name = complete_ability_name(ability_name)
	
	await abilities[ability_name].stop()


func reset_ability(ability_name: String):
	ability_name = complete_ability_name(ability_name)
	
	abilities[ability_name].reset()


func complete_ability_name(ability_name: String) -> String:
	return ability_name + "Controller"