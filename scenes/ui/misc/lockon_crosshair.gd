extends Sprite3D

var cam: XRCamera3D = null
var enemy: CharacterBody3D = null


func _process(_delta: float) -> void:
	if cam && enemy:
		position = enemy.global_transform.origin
		
		var look_pos = cam.global_transform.origin
		look_at(look_pos, cam.global_transform.basis.y)
