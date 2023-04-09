extends Node3D

var SHELL = preload("res://Entities/Attacks/laser_attack.tscn")

var shoot_array = []

var current_shot_idx = -1

func _on_cooldown_timeout():
	if get_node("/root/Main_level").PLAYER.camera_mode == 0:
		print("Incoming artillery strike!")
		global_position = get_node("/root/Main_level").PLAYER.global_position
		var shots = randi()%20+20
		shoot_array.clear()
		#$markers.scale = Vector3(0.5+randf()*0.5, 7, 0.5+randf()*0.5) * 0.1
		for m in $markers.get_children():
			m.get_child(0).scale = Vector3(1, 1, 1)
			m.get_child(0).global_scale(Vector3(1,1,1)/$markers.scale)
			#print(m.get_child(0).global_transform.basis.get_scale())
			pass
		for m in shots:
			shoot_array.append( $markers.get_children().pick_random().get_child(0) )
		$step2.start()
	else:
		$cooldown.start()

func _on_step_2_timeout():
	global_position = get_node("/root/Main_level").PLAYER.global_position
	current_shot_idx += 1
	if current_shot_idx == shoot_array.size():
		$cooldown.wait_time = 40 + (randf()*30)
		#$cooldown.wait_time = 2
		$cooldown.start()
		current_shot_idx = -1
	else:
		shoot_shell()
		shoot_shell()
		shoot_shell()
		shoot_shell()
		$step2.start()

func shoot_shell():
	var shell = SHELL.instantiate()
	shell.global_transform = shoot_array.pick_random().global_transform
	shell.damage_everyone = true
	get_node("/root/Main_level").add_child(shell)
