extends CharacterBody3D


const SPEED = 2.0
const JUMP_VELOCITY = 4.5

var movement_direction = Vector2(0, 0)

var enemies = []

var health = 30
var stun = false

var safespace_factor = randf() * 3 - 0.5
var pursue_factor = randf() * 2 - 1

var wander_direction = Vector2(randf()*2-1, randf()*2-1)  * 3

var EXPLOSSION = preload("res://FX/explossion_fx.tscn")
var LASER = preload("res://Entities/Attacks/laser_attack.tscn")
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	if health <= 0:
		kill()
	var distance_to_player = (global_position - get_node("/root/Main_level").PLAYER.global_position).length()
	
	if distance_to_player < 4:
		if !stun and get_node("/root/Main_level").PLAYER.alive:
			$Visual.look_at(get_node("/root/Main_level").PLAYER.global_position)
			if randi()%60 == 0:
				shoot()
	else:
		$Visual.rotation.y = Vector2(velocity.x, -velocity.z).angle() - PI/2
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = get_movement_direction()
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func get_movement_direction():
	if stun:
		return Vector2(0, 0)
	return movement_direction.normalized()
	pass

func calculate_movement_direction():
	movement_direction = wander_direction
	enemies.clear()
	for body in $entity_scan.get_overlapping_bodies():
		if body.is_in_group("ENEMY") and body.is_in_group("walking"):
			enemies.append(body)
			var deltapos = Vector2(global_position.x, global_position.z) - Vector2(body.global_position.x, body.global_position.z) 
			if deltapos.length() < 1.6:
				movement_direction += deltapos * 3
			
		if body.is_in_group("PLAYER") and body.alive:
			var deltapos = Vector2(global_position.x, global_position.z) - Vector2(body.global_position.x, body.global_position.z) 
			if deltapos.length() < 2.5:
				movement_direction += deltapos * 0.5
			elif deltapos.length() > 2.5:
				movement_direction += wander_direction
	pass

func damage(value):
	health -= value

func kill():
	var explossion = EXPLOSSION.instantiate()
	explossion.global_position = global_position + Vector3(0, 1, 0)
	get_node("/root/Main_level/enemies").add_child(explossion)
	queue_free()
	pass


func _on_wander_timeout():
	wander_direction = Vector2(randf()*2-1, randf()*2-1) * 3
	pass # Replace with function body.

func shoot():
	var laser = LASER.instantiate()
	laser.global_transform = $Visual/shooter.global_transform
	get_node("/root/Main_level/bullets").add_child(laser)
	
	$stun.start()
	stun = true
	pass

func _on_stun_timeout():
	stun = false
	pass # Replace with function body.
