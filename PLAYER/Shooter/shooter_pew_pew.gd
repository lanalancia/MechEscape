extends Node3D

var can_shoot = true
var plasma = preload("res://PLAYER/Shooter/plasmaball.tscn")

func shoot():
	if can_shoot:
		$cooldown.start()
		can_shoot = false
		var plasma_instance = plasma.instantiate()
		plasma_instance.velocity = -global_transform.basis.z * 0.01
		plasma_instance.global_transform = global_transform
		get_tree().root.get_node("Main_level/bullets").add_child(plasma_instance)
	pass


func _on_cooldown_timeout():
	can_shoot = true
	pass # Replace with function body.
