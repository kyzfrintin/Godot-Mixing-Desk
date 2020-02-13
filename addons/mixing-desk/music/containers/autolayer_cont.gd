extends Node

enum play_mode {additive, single, pad}
var num = 0.0
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

var cont = "autolayer"

func _ready():
	get_node("../..").connect("beat", self, "_update")
	target = get_node(target_node)

func _update(beat):
	var layer = layer_max
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
		layer = clamp(floor(num), 0, get_child_count())
	match play_style:
		0:
			layer_min = -1
			layer_max = layer
		1:
			layer_max = layer
			layer_min = layer - 1
		2:
			if pad != 0:
				layer_min = layer - pad
				layer_max = layer + pad
	_fade_layers()

func _fade_layers():
	for i in range(get_child_count()):
		var child = get_child(i)
		if i != -1:
			if i < layer_min or i > layer_max:
				_fade_to(child,-60)
			else:
				_fade_to(child,0)

func _fade_to(target, vol):
	var is_match
	var cvol = target.volume_db
	var sum = vol - cvol
	is_match = abs(cvol-vol) < .01
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
