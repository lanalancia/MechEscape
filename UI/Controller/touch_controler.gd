extends Node2D

var lvalue = Vector2()
var rvalue = Vector2()

var screen_scale_factor
var margin_sticks = Vector2(200, 128)
var resize_sticks = 1.3

func _ready():
	adjust_sticks()

func set_lstick(move):
	lvalue = move
	pass

func set_rstick(move):
	rvalue = move
	pass

func get_values():
	return [lvalue, rvalue]

func adjust_sticks():
	var screen_scale = get_viewport_rect().size / Vector2(1152, 648)
	screen_scale_factor = (screen_scale.x + screen_scale.y) / 2
	
	$lpos/virtual_joystick.scale = Vector2(1, 1) * screen_scale_factor * resize_sticks
	$rpos/virtual_joystick.scale = Vector2(1, 1) * screen_scale_factor * resize_sticks
	
	$lpos.position.x = (margin_sticks.x * screen_scale_factor)
	$lpos.position.y = get_viewport_rect().size.y - (margin_sticks.y * screen_scale_factor)
	$rpos.position.x = get_viewport_rect().size.x - (margin_sticks.x * screen_scale_factor)
	$rpos.position.y = get_viewport_rect().size.y - (margin_sticks.y * screen_scale_factor)
