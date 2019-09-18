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
export(bool) var auto_transition
export(NodePath) var auto_signal_node
export(String) var auto_signal
export(String, "Beat", "Bar") var transition_type

func _ready():
	if auto_transition:
		var sig_node = get_node(auto_signal_node)
		sig_node.connect(auto_signal, self, "_transition", [transition_type])

func _transition(type):
	match type:
		"Beat":
			get_parent().queue_beat_transition(name)
		"Bar":
			get_parent().queue_bar_transition(name)

func _get_core():
	for i in get_children():
		if i.cont == "core":
			return i