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
