extends Node

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

var cont = "autolayer"
var process = false

func _process(delta):
	if !process: return
	var num : float
	if automate:
		num = get_node(target_node).get(target_property)
		if !invert:
			num = num + min_range
			num /= max_range
		else:
			num *= -1
			num += max_range
			num /= (max_range - min_range)
		num *= (get_child_count())
	var layer = clamp(floor(num), 0, get_child_count())
	if pad != 0:
		layer_min = layer - pad
		layer_max = layer + pad
	else:
		layer_max = layer
	#below range
	for i in range(0, layer_min):
		_fade_to(get_child(i), -60)
	#range
	for i in range(layer_min, layer_max):
		_fade_to(get_child(i), 0)
	#above range
	for i in range(layer_max + 1, get_child_count()):
		_fade_to(get_child(i), -60)

func _fade_to(target, vol):
	var is_match
	var above
	if target.volume_db > vol:
		var sum = vol - target.volume_db
		is_match = sum > -1
		above = false
	else:
		var sum = target.volume_db - vol
		is_match = sum > -1
		above = true
	if !is_match:
		if above:
			target.volume_db += track_speed
		else:
			target.volume_db -= track_speed