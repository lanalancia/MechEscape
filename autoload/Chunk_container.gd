extends Node

var chunk_array = []

func _ready():
	chunk_array.append(preload("res://chunks/RuinedCity/City_chunk_0.tscn"))
	chunk_array.append(preload("res://chunks/RuinedCity/city_chunk_1.tscn"))
	chunk_array.append(preload("res://chunks/RuinedCity/city_chunk_2.tscn"))
	chunk_array.append(preload("res://chunks/RuinedCity/city_chunk_3.tscn"))

func get_chunk(idx):
	return chunk_array[idx]
	pass
