extends Node2D

var dvols = []
var dpitches = []
var timeroot

func _ready():
	for i in get_children():
		if is_3d(i):
			dvols.append(i.unit_db)
		else:
			dvols.append(i.volume_db)
		dpitches.append(i.pitch_scale)

func is_3d(sound):
	if sound.is_class("AudioStreamPlayer3D"):
		return true