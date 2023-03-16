extends BaseState
class_name GrabbingState

func grip_released():
	change_state.call("unarmed")
