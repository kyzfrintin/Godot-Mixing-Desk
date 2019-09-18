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
export(float) var track_speed

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
#		print(target.volume_db)
		if above:
			target.volume_db += track_speed
		else:
			target.volume_db -= track_speed
