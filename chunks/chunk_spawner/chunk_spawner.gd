extends Node3D


@export var spawnable_chunks: Array[int] = [1]
@export var chunk : String
# Called when the node enters the scene tree for the first time.
func _ready():
	hide()

func spawn_chunk():
	var chunk_idx = spawnable_chunks.pick_random()
	var new_chunk = Chunks.get_chunk(chunk_idx).instantiate()
	new_chunk.global_transform = global_transform
	new_chunk.prev_chunk = get_parent().get_parent()
	get_parent().get_parent().get_parent().add_child(new_chunk)
	pass
