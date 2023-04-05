extends CharacterBody3D


const SPEED = 3.0
const JUMP_VELOCITY = 4.5

var jet_charge = 0

var input_lock = false
var lock_vector = Vector2()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var CONTROLLER : NodePath
@export var CAMERA_RAILS : NodePath
@onready var rails = [get_node(CAMERA_RAILS).get_child(0), get_node(CAMERA_RAILS).get_child(1), get_node(CAMERA_RAILS).get_child(2)]

var camera_mode = 0

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

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
	match camera_mode:
		-1:
			input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		0: #top-down
			input_dir = get_node(CONTROLLER).get_values()[0]
			$camera_holder.global_transform = $camera_holder.global_transform.interpolate_with(rails[0].global_transform, 0.15)
			
			#var camera_shift_vector = clamp($camera_holder/Camera3D.position, ) 
			#$camera_holder/Camera3D.position.x = clamp( $camera_holder/Camera3D.position.x + get_node(CONTROLLER).get_values()[0].x * 0.1, -1, 1 )
			#$camera_holder/Camera3D.position.y = clamp( $camera_holder/Camera3D.position.y - get_node(CONTROLLER).get_values()[0].y * 0.1, -1, 1 )
			
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
	
	animate(camera_mode)
	
	#print(jet_charge)
	if input_lock:
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
	match camera_mode:
		0:
			$legs.rotation.x = 0
			$legs.rotation.z = 0
			$torso/handl.rotation.x = 0
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
	
#func change_camera_mode(idx):
	
	#pass

func lock_input():
	$input_lock.start()
	input_lock = true

func _on_input_lock_timeout():
	input_lock = false
