extends CharacterBody3D


const SPEED = 3.0
const JUMP_VELOCITY = 4.5

var jet_charge = 0

var input_lock = false
var lock_vector = Vector2()

var health = 100

var alive = true

var nearby_enemies = []

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var CONTROLLER : NodePath
@export var CAMERA_RAILS : NodePath
@onready var rails = [get_node(CAMERA_RAILS).get_child(0), get_node(CAMERA_RAILS).get_child(1), get_node(CAMERA_RAILS).get_child(2)]

var camera_mode = 0
var EXPLOSION = preload("res://FX/explossion_fx.tscn")

var aim_asist = false

func _ready():
	$torso/ray_l.add_exception(self)
	$torso/ray_r.add_exception(self)
	pass

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if health <= 0:
		alive = false
		health = 0
	
	if !alive:
		if randi()%70 == 0:
			$hitbox/damage_visualisation_points.get_children().pick_random().add_child(EXPLOSION.instantiate())
	
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("1"):
		camera_mode = 0
	if Input.is_action_just_pressed("2"):
		camera_mode = 1
	if Input.is_action_just_pressed("3"):
		camera_mode = 2
	
	
	
	var input_dir = Vector2.ZERO
	if alive:
		match camera_mode:
			-1:
				input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
			0: #top-down
				input_dir = get_node(CONTROLLER).get_values()[0]
				$camera_holder.global_transform = $camera_holder.global_transform.interpolate_with(rails[0].global_transform, 0.15)
				
				$camera_holder/Camera3D.position.x += get_node(CONTROLLER).get_values()[0].x * 0.1
				$camera_holder/Camera3D.position.y -= get_node(CONTROLLER).get_values()[0].y * 0.1
				
				if $camera_holder/Camera3D.position.length() > 0.3:
					$camera_holder/Camera3D.position = $camera_holder/Camera3D.position.normalized() * 0.3
			1: #side
				$camera_holder.global_transform = $camera_holder.global_transform.interpolate_with(rails[1].global_transform, 0.15)
				input_dir.x = 0
				if get_node(CONTROLLER).get_values()[0].y <= 0.8 or !is_on_floor():
					input_dir.y = -get_node(CONTROLLER).get_values()[0].x
				
				if is_on_floor() and get_node(CONTROLLER).get_values()[0].y > 0.7:
					jet_charge += delta*4
				if is_on_floor() and get_node(CONTROLLER).get_values()[0].y < 0.7:
					jet_charge -= delta*5
				
				jet_charge = clamp(jet_charge, 0, 1.5)
				#print(jet_charge)
				if is_on_floor() and get_node(CONTROLLER).get_values()[0].y < -0.5 and jet_charge >= 0.7:
					velocity.y = 1
					jet_charge -= 0.01
				if !is_on_floor() and get_node(CONTROLLER).get_values()[0].y < 0 and jet_charge > 0:
					velocity.y += 0.3
					jet_charge -= 0.01
			2: #flying mode (backward)
				$camera_holder.global_transform = $camera_holder.global_transform.interpolate_with(rails[2].global_transform, 0.15)
				pass
			_:
				pass
		
		#Aim assist, TODO
		if aim_asist:
			var closest_enemy = null
			var closest_dot = 0.996
			for e in nearby_enemies:
				if weakref(e).get_ref():
					var vector_direction_l = e.global_position - $torso/handl.global_position
					var try_dot = vector_direction_l.dot(-$torso.global_transform.basis.z)
					if try_dot > closest_dot:
						closest_enemy = e
						closest_dot = try_dot
			
			if closest_enemy != null:
				$torso/handl.look_at(closest_enemy.global_position, Vector3(1, 0, 0))
				$torso/handl.look_at(closest_enemy.global_position, Vector3(0, 1, 0))
			else:
				$torso/handl.rotation *= 0
			
		if get_node(CONTROLLER).get_values()[1].length() > 0.8:
			$torso/handl/shooter.shoot()
			$torso/handr/shooter.shoot()
		animate(camera_mode)
	
	var repel_wall_vector = Vector2()
	repel_wall_vector.x += (int($torso/ray_l.is_colliding()) + -int($torso/ray_r.is_colliding())) * 0.3
	
	repel_wall_vector = repel_wall_vector.rotated(-$torso.rotation.y)
	input_dir += repel_wall_vector
	
	if input_lock or !alive:
		input_dir = Vector2()
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED * input_dir.length()
		velocity.z = direction.z * SPEED * input_dir.length()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	velocity.y = clamp(velocity.y, -10, 4.5)
	move_and_slide()


func animate(camera_mode):
	if $torso/ray_l.is_colliding():
		$anim_left.play("hand_left_forward")
	else:
		$anim_left.play("hand_left_idle")
	
	if $torso/ray_r.is_colliding():
		$anim_left.play("hand_right_forward")
	else:
		$anim_left.play("hand_right_idle")
	
	if get_node(CONTROLLER).get_values()[0].length() > 0.1:
		if $anim_legs.current_animation != "walk":
			$anim_legs.play("walk")
	else:
		$anim_legs.play("idle")
	
	match camera_mode:
		0:
			$torso/handl.rotation.x = 0
			$torso/handr.rotation.x = 0
			$legs.rotation.x = 0
			$legs.rotation.z = 0
			if get_node(CONTROLLER).get_values()[0].length() > 0.1:
				var target_vector_legs = get_node(CONTROLLER).get_values()[0].rotated(PI/2) * Vector2(1, -1)
				var current_vector_legs = Vector2(1, 0).rotated($legs.rotation.y)
				
				if current_vector_legs.dot(target_vector_legs) > 0:
					current_vector_legs = current_vector_legs.move_toward(target_vector_legs, 0.1)
				else:
					current_vector_legs = current_vector_legs.move_toward(target_vector_legs.rotated(PI), 0.1)
				
				$legs.rotation.y = current_vector_legs.angle()
			
			$torso.rotation.x = 0
			$torso.rotation.z = 0
			if get_node(CONTROLLER).get_values()[1].length() > 0.01:
				var target_vector_torso = get_node(CONTROLLER).get_values()[1].rotated(PI/2) * Vector2(1, -1)
				var current_vector_torso = Vector2(1, 0).rotated($torso.rotation.y)
				
				current_vector_torso = current_vector_torso.move_toward(target_vector_torso, 0.4)
				
				$torso.rotation.y = current_vector_torso.angle()
			
		1:
			$legs.rotation.x = 0
			$legs.rotation.z = 0
			if get_node(CONTROLLER).get_values()[0].length() > 0.1:
				var target_vector_legs = Vector2(0, 0)
				var current_vector_legs = Vector2(1, 0).rotated($legs.rotation.y)

				target_vector_legs = Vector2(1, 0)
				current_vector_legs = current_vector_legs.move_toward(target_vector_legs, 0.1)
				$legs.rotation.y = current_vector_legs.angle()
			
			$torso.rotation.x = 0
			$torso.rotation.z = 0
			if get_node(CONTROLLER).get_values()[1].length() > 0.01:
				var target_vector_torso = Vector2(0, 0)
				var current_vector_torso = Vector2(1, 0).rotated($torso.rotation.y)
				
				if get_node(CONTROLLER).get_values()[1].x > 0:
					current_vector_torso = current_vector_torso.move_toward(Vector2(1, -0.01), 0.4)
				else:
					current_vector_torso = current_vector_torso.move_toward(Vector2(-1, -0.01), 0.4)
				$torso.rotation.y = current_vector_torso.angle()


				var target_vector_hand = get_node(CONTROLLER).get_values()[1].rotated(0) * Vector2(1, -1)
				var current_vector_hand = Vector2(1, 0).rotated($torso/handr.rotation.x)
				
				if get_node(CONTROLLER).get_values()[1].x > 0:
					current_vector_hand = current_vector_hand.move_toward(target_vector_hand, 0.6)
				else:
					current_vector_hand = current_vector_hand.move_toward(target_vector_hand * Vector2(-1, 1), 0.6)
					
				$torso/handr.rotation.x = current_vector_hand.angle()
				$torso/handl.rotation.x = $torso/handr.rotation.x
			pass
		_:
			$legs.transform = Transform3D()
			$torso.transform = Transform3D()
	
func damage(value):
	health -= value
	$hitbox/damage_visualisation_points.get_children().pick_random().add_child(EXPLOSION.instantiate())
	pass

func kill():
	alive = false
	$anim_legs.pause()
	pass

func lock_input():
	$input_lock.start()
	input_lock = true

func _on_input_lock_timeout():
	input_lock = false


func _on_aim_assist_area_entered(area):
	if area.is_in_group("HITBOX") and area.get_parent().is_in_group("ENEMY"):
		#nearby_enemies.append(area.get_parent())
		#TODO
		pass


func _on_aim_assist_area_exited(area):
	if area.is_in_group("HITBOX") and area.get_parent().is_in_group("ENEMY"):
		nearby_enemies.remove_at( nearby_enemies.find(area.get_parent()) )
	pass # Replace with function body.
