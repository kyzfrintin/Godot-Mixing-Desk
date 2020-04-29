extends Node

var cont = "autofade"
enum play_type {random, all}
export(play_type) var play_style
export var toggle : bool = false
export(NodePath) var target_node
export(String) var target_property
export(float) var min_range
export(float) var max_range
export(bool) var invert
export(float, 0.0, 1.0) var track_speed

var param
var target

func _ready():
	get_node("../..").connect("beat", self, "_update")
	target = get_node(target_node)

func _update(beat):
	param = target.get(target_property)
	if !toggle:
		var vol : float
		if !invert:
			vol -= min_range
			vol /= (max_range - min_range)
		else:
			vol = param * -1
			vol += max_range
			vol /= (max_range - min_range)
		vol = (vol*65) - 65
		vol = clamp(vol,-65,0)
		for i in get_children():
			_fade_to(i, vol)
	else:
		if param:
			for i in get_children():
				_fade_to(i, 0)
		else:
			for i in get_children():
				_fade_to(i, -65)

func is_equal(a : float,b : float):
	return int(a) == int(b)

func _fade_to(target, vol):
	var is_match
	var cvol = target.volume_db
	is_match = is_equal(cvol,vol)
	if !is_match:
		if cvol > vol:
			cvol -= 1
		else:
			cvol = lerp(cvol,vol,track_speed)
		target.volume_db = cvol
	else:
		if vol == 0:
			if cvol != vol:
				target.volume_db = 0
		elif cvol != vol:
			target.volume_db = vol
