extends Node3D

@export var PLAYER_SPAWN : NodePath = "."
# Called when the node enters the scene tree for the first time.
func _ready():
	print("Loading: ", name)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_player_spawn():
	return get_node(PLAYER_SPAWN)
