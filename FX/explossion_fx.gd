extends Node3D

signal explossion_finished
func _process(delta):
	
	if visible:
		$MeshInstance3D.scale -= scale * delta
		if $MeshInstance3D.scale.x <= 0:
			emit_signal("explossion_finished")
			queue_free()
