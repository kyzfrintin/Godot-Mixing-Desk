extends Node

enum play_mode {additive, single, pad}
export(play_mode) var play_style
export(int) var layer_min
export(int) var layer_max
export(bool) var automate = false
export(NodePath) var target_node
export(String) var target_property
export(float) var min_range
export(float) var max_range
export(int) var pad = 0
export(bool) var invert
export(float) var track_speed

var target
var num = 0.0
var t_layer
var cont = "autolayer"

func _ready():
	get_node("../..").connect("beat", self, "_update")
	target = get_node(target_node)

func _update(beat):
	t_layer = layer_max
	if automate:
		num = target.get(target_property)
		if !invert:
			num -= min_range
			num /= (max_range - min_range)
		else:
			num *= -1
			num += max_range
			num /= (max_range - min_range)
		num *= (get_child_count())
		t_layer = clamp(floor(num), -1, get_child_count() - 1)
	match play_style:
		0:
			layer_min = -1
			layer_max = t_layer
		1:
			layer_min = t_layer
			layer_max = t_layer
		2:
			if pad != 0:
				layer_min = t_layer - pad
				layer_max = t_layer + pad
	_fade_layers()

func _fade_layers():
	for i in range(get_child_count()):
		var child = get_child(i)
		if i != -1:
			if i < layer_min or i > layer_max:
				_fade_to(child,-65)
			else:
				_fade_to(child,0)
				
func is_equal(a : float,b : float):
	return int(a) == int(b)

func _fade_to(target, vol):
	var is_match
	var cvol = target.volume_db
	var sum = vol - cvol
	is_match = is_equal(vol,cvol)
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
