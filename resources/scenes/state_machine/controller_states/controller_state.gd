extends State
class_name ControllerState


var controller: XRController3D
var controller_id: int


func _ready():
	await owner.ready
	
	controller = owner as XRController3D
	assert(controller != null)
	controller_id = controller.get_tracker_hand()
