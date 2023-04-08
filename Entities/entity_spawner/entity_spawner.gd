extends Node

@export_range(0, 1, 0.01) var chance_empty : float
func _ready():
	for s in get_children():
		if s.is_in_group("SPAWNPOINT"):
			if randf() > chance_empty:
				var new_entity = s.spawnable_entities.pick_random()
				new_entity.global_transform = s.global_transform
				get_node("/root/Main_level/enemies").add_child(new_entity)
			queue_free()
