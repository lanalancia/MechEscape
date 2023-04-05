extends Node

var chunk_array = []

func _ready():
	chunk_array.append(preload("res://chunks/RuinedCity/City_chunk_0.tscn"))    #0
	chunk_array.append(preload("res://chunks/RuinedCity/city_chunk_1.tscn"))    #1
	chunk_array.append(preload("res://chunks/RuinedCity/city_chunk_2.tscn"))    #2
	chunk_array.append(preload("res://chunks/RuinedCity/city_chunk_3.tscn"))    #3
	chunk_array.append(preload("res://chunks/RuinedCity/city_thin_0.tscn"))     #4
	chunk_array.append(preload("res://chunks/RuinedCity/city_thin_1.tscn"))     #5
	chunk_array.append(preload("res://chunks/RuinedCity/city_thin_2.tscn"))     #6

func get_chunk(idx):
	return chunk_array[idx]
	pass
