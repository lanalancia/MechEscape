extends Area3D


var damage_everyone = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Visual/charge.scale.x = 2 * ($step2.wait_time - ($step2.wait_time - $step2.time_left))
	$Visual/charge.scale.z = $Visual/charge.scale.x

func _on_step_1_timeout():
	var entities = get_overlapping_areas()
	for area in entities:
		if area.is_in_group("HITBOX") and area.get_parent().is_in_group("PLAYER") or area.is_in_group("HITBOX") and damage_everyone:
			area.get_parent().damage(18)
		if area.is_in_group("PROJECTILE"):
			area.set_to_dieout()
	$step2.start()
	$Visual/charge.show()
	$Visual/aim.hide()


func _on_step_2_timeout():
	queue_free()
	pass
