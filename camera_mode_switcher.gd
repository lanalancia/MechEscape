extends Node3D

@export var push_left = false
@export var push_right = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	pass # Replace with function body.

func _on_mode_1_body_entered(body):
	if body.is_in_group("PLAYER"):
		if body.camera_mode != 1:
			body.lock_input()
		body.camera_mode = 1
		body.rotation.y = get_parent().global_rotation.y
	pass # Replace with function body.


func _on_mode_0_body_entered(body):
	if body.is_in_group("PLAYER"):
		if body.camera_mode != 0:
			body.lock_input()
		body.camera_mode = 0
		body.rotation.y = 0
	pass # Replace with function body.
