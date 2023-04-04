extends Area3D

func _on_body_entered(body):
	if body.is_in_group("PLAYER"):
		if randi()%9 > 0:
			print(get_parent().name)
			get_parent().lock_backtrack()
		for n in get_parent().get_node("Attach_points").get_children():
			n.spawn_chunk()
		queue_free()
