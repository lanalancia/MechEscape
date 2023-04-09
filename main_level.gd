extends Node3D


@export var initial_cnunk : PackedScene
@onready var PLAYER = $PLAYER 

# Called when the node enters the scene tree for the first time.
func _ready():
	#change_root_scene_to(load("res://chunks/TestingPlayground/playground_1.tscn"))
	#var newscene = preload("res://chunks/RuinedCity/City_chunk_0.tscn")
	$chunks.add_child( initial_cnunk.instantiate() )
	pass


func _process(delta):
	$Camera_rails/top.position = Vector3(0, 7, 0)
	$Camera_rails/side.position = Vector3(7, 2, 0)
	$Camera_rails.transform = PLAYER.transform
	#$Camera_rails.rotation.y = PLAYER.rotation.y 
	$floor.position.x = PLAYER.position.x
	$floor.position.z = PLAYER.position.z
	update_UI()
	
	pass

func update_UI():
	var screen_scale = $UI.get_viewport_rect().size / Vector2(1152, 648) #Vector2(1152, 648)
	var screen_scale_factor = (screen_scale.x + screen_scale.y) / 2
	$UI/healthbar.scale = Vector2(1, 1) * screen_scale_factor
	
	$UI/healthbar/HP/hp_line.size.x = PLAYER.health
	if !PLAYER.alive:
		$UI/TouchScreenButton.show()
	pass

func change_1root_scene_to(scene):
	print(scene)
	for n in $chunks.get_children():
		n.name = n.name+"_FREED"
		n.queue_free()
	$chunks.add_child( scene.instantiate() )
	PLAYER.global_position = $chunks.get_child(0).get_player_spawn().global_position
	PLAYER.velocity *= 0
	pass


func _on_touch_screen_button_pressed():
	get_tree().reload_current_scene()
	pass # Replace with function body.
