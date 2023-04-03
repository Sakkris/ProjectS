extends Node
class_name AbilityManager

@export_enum("Left:1", "Right:2") var controller_id
@export var velocity_component: VelocityComponent

@onready var gun_nuzzle = $"../GunNuzzle"

var abilities = {}


func _ready() -> void:
	await velocity_component.ready
	
	for child in get_children():
		if child.is_class("Ability"):
			child.velocitiy_component = velocity_component
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
