extends Node

var cont = "autofade"
enum play_type {random, all}
export(play_type) var play_style
export var toggle : bool = false
export(NodePath) var target_node
export(String) var target_property
export(float) var min_range = 0.0
export(float) var max_range = 1.0
export(bool) var invert
export(float, 0.0, 1.0) var track_speed

var param
var target

func _ready():
	get_node("../..").connect("beat", self, "_update")
	target = get_node(target_node)
	init_volume()

func _update(beat):
	param = target.get(target_property)
	if !toggle:
		var vol := _get_range_vol()
		for i in get_children():
			_fade_to(i, vol)
	else:
		for i in get_children():
			if param:
				_fade_to(i, 0)
			else:
				_fade_to(i, -65)
				
func init_volume():
	param = target.get(target_property)
	if !toggle:
		var vol := _get_range_vol()
		for i in get_children():
			i.volume_db = vol
	else:
		for i in get_children():
			if param:
				i.volume_db = 0
			else:
				i.volume_db = -65

func _get_range_vol() -> float:
	var vol: float = param
	if !invert:
		vol -= min_range
	else:
		vol *= -1
		vol += max_range
	vol /= abs(max_range - min_range)
	vol = (vol*65) - 65
	vol = clamp(vol,-65,0)

	return vol

func is_equal(a : float,b : float):
	return int(a) == int(b)

func _fade_to(target, vol):
	var is_match
	var cvol = target.volume_db
	is_match = is_equal(cvol,vol)
	if !is_match:
		if cvol > vol:
			if track_speed < 1.0:
				cvol -= 1.5 / (1.0 - track_speed )
			else:
				cvol = vol
		else:
			cvol = lerp(cvol,vol,track_speed)
		target.volume_db = cvol
	else:
		if vol == 0:
			if cvol != vol:
				target.volume_db = 0
		elif cvol != vol:
			target.volume_db = vol
