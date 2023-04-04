extends Node3D

@export var PLAYER_SPAWN : NodePath = "."
@export var GATES : NodePath

func _ready():
	print("Loading: ", name)

func get_player_spawn():
	return get_node(PLAYER_SPAWN)

func lock_backtrack():
	
	if GATES != ^"":
		for n in get_parent().get_children():
			if n != self:
				n.queue_free()
		get_node(GATES).trigger()
	pass
