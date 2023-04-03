extends Node3D

@onready var PLAYER = $PLAYER #TODO
var sockets = []

# Called when the node enters the scene tree for the first time.
func _ready():
	change_root_scene_to(load("res://chunks/TestingPlayground/playground_1.tscn"))

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		change_root_scene_to(load("res://chunks/TestingPlayground/playground_1.tscn"))
		
	pass

func append_scene(socket_idx):
	
	pass

func change_root_scene_to(scene : PackedScene):
	sockets.clear()
	for n in $chunks.get_children():
		n.name = n.name+"_FREED"
		n.queue_free()
	$chunks.add_child(scene.instantiate() )
	PLAYER.global_position = $chunks.get_child(0).get_player_spawn().global_position
	pass
