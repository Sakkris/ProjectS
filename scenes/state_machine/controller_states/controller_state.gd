extends State
class_name ControllerState


var controller: XRController3D
var controller_id: int


func _ready():
	await owner.owner.ready
	
	controller = owner.owner as XRController3D
	controller_id = controller.get_tracker_hand()
	assert(controller != null)
