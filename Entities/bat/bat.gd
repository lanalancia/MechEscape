extends CharacterBody3D


var SPEED = 5.0
var health = 15

@onready var PLAYER = get_node("/root/Main_level/PLAYER")
var EXPLOSSION = preload("res://FX/explossion_fx.tscn")

var is_hunting = false
var wander_direction = Vector3(randf()-0.5, randf()-0.5, randf()-0.5).normalized()

var is_charging = false

func _physics_process(delta):
	if health <= 0:
		kill()
	var input_dir = wander_direction * 4
	if !is_charging:
		if (global_position - (PLAYER.global_position + Vector3(0, 1.432, 0))).length() < 4:
			is_hunting = true
			SPEED = 3
		else:
			is_hunting = false
			SPEED = 1
	
	input_dir -= (global_position - (PLAYER.global_position + Vector3(0, 1.432, 0))) * 0.1
	
	if is_hunting:
		$visual.look_at(PLAYER.global_position, global_transform.basis.y)
		if PLAYER.camera_mode == 0:
			input_dir.y -= (global_position - (PLAYER.global_position + Vector3(0, 1.432, 0))).y * 5
		
		if randi()%150 == 0:
			$visual.rotation = Vector3()
			is_charging = true
			is_hunting = false
			look_at((PLAYER.global_position + Vector3(0, 1.432, 0)), global_transform.basis.x)
			look_at((PLAYER.global_position + Vector3(0, 1.432, 0)), global_transform.basis.y)
			rotation.z = 0
			$charge.start()
			$visual/damage_zone.set_deferred("monitoring", true)
	
	if is_on_floor():
		input_dir.y = 5
	input_dir = input_dir.normalized()
	$visual/Blade.visible = is_charging
	if is_charging:
		velocity = -global_transform.basis.z * 4.5
	else:
		velocity.x = input_dir.x * SPEED
		velocity.y = input_dir.y * SPEED
		velocity.z = input_dir.z * SPEED

	move_and_slide()


func _on_movement_change_timeout():
	wander_direction = Vector3(randf()-0.5, randf()-0.5, randf()-0.5).normalized()
	pass # Replace with function body.


func _on_charge_timeout():
	is_charging = false
	rotation.x = 0
	$visual/damage_zone.set_deferred("monitoring", false)
	pass # Replace with function body.

func damage(value):
	health -= value

func kill():
	var explossion = EXPLOSSION.instantiate()
	explossion.global_position = global_position + Vector3(0, 1, 0)
	get_node("/root/Main_level/enemies").add_child(explossion)
	queue_free()
	pass


func _on_damage_zone_area_entered(area):
	if area.is_in_group("HITBOX") and area.get_parent().is_in_group("PLAYER"):
		area.get_parent().damage(8)
		kill()
	pass # Replace with function body.
