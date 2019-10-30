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

func _ready():
	get_node("../..").connect("beat", self, "_update")

func _update(beat):
	param = get_node(target_node).get(target_property)
	if !toggle:
		var vol : float
		if !invert:
			vol = param + min_range
			vol /= max_range
		else:
			vol = param * -1
			vol += max_range
			vol /= (max_range - min_range)
		vol = (vol*60) - 60
		vol = clamp(vol,-60,0)
		for i in get_children():
			_fade_to(i, vol)
	else:
		if param:
			for i in get_children():
				_fade_to(i, 0)
		else:
			for i in get_children():
				_fade_to(i, -60)

func _check_equal(a : float,b : float):
	var aa = floor(a)
	var bb = floor(b)
	return (aa == bb)

func _fade_to(target, vol):
	var is_match
	var cvol = target.volume_db
	var sum = vol - cvol
	is_match = _check_equal(cvol,vol)
	if !is_match:
		cvol = lerp(cvol,vol,track_speed)
		target.volume_db = cvol
	else:
		if vol == 0:
			if cvol != vol:
				target.volume_db = 0
				print('full volume')
		elif cvol != vol:
			target.volume_db = vol
