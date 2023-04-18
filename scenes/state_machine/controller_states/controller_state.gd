extends State
class_name ControllerState


var controller: XRController3D
var controller_id: int


func _ready():
	await GameEvents.game_start
	await get_tree().create_timer(1).timeout # Esperar que os comandos recevam o id
	
	controller = owner as XRController3D
	assert(controller != null)
	controller_id = controller.get_tracker_hand()
