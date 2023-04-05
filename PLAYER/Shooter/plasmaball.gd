extends Area3D

var angular_speed = 9
var damage = 10

var velocity = Vector3(0, 0, 0)

func _ready():
	velocity += (Vector3(randf(), randf() * 0.5, randf()) - Vector3(0.5, 0.5, 0.5)) * 0.0023
	
func _process(delta):
	
	$sup1.rotate_object_local(Vector3(1, 0, 0), angular_speed * delta)
	$sup2.rotate_object_local(Vector3(1, 0, 0), (angular_speed + 4) * delta)
	$sup3.rotate_object_local(Vector3(1, 0, 0), (angular_speed + 8) * delta)
	
	global_position += velocity * 5
	if $explossion.visible:
		$explossion.scale -= Vector3(1, 1, 1) * delta * 2
		if $explossion.scale.x < 0:
			queue_free()

func _on_area_entered(area):
	if area.is_in_group("EVIL") and area.is_in_group("HITBOX"):
		area.get_parent().damage(damage)
		set_to_dieout()

func _on_lifetime_timeout():
	set_to_dieout()

func set_to_dieout():
	monitorable = false
	monitoring = false
	velocity *= 0
	$explossion.show()
	$MeshInstance3D.hide()
	$sup1.hide()
	$sup2.hide()
	$sup3.hide()
	pass

func _on_body_entered(body):
	if body is StaticBody3D:
		set_to_dieout()
