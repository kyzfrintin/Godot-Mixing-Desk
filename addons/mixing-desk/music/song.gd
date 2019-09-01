extends Node

#internal vars
var fading_out : bool = false
var fading_in : bool = false
var muted_tracks = []
var concats : Array

#external properties
export(int) var tempo
export(int) var bars
export(int) var beats_in_bar
export(float) var transition_beats
export(bool) var loop

func _get_core():
	for i in get_children():
		if i.cont == "core":
			return i