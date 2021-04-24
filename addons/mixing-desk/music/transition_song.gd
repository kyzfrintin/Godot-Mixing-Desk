extends Node

#internal vars
var song_type = "transition"
var fading_out : bool = false
var fading_in : bool = false
var muted_tracks = []
var concats : Array
var ignore = true

#external properties
export(int) var tempo
export(int) var bars
export(int) var beats_in_bar
export(NodePath) var target_song
export(float) var transition_beats
export(bool) var auto_transition
export(NodePath) var auto_signal_node
export(String) var auto_signal
export(String, "Beat", "Bar") var transition_type
export(String) var bus = "Music"

func _ready():
	if auto_transition:
		var sig_node = get_node(auto_signal_node)
		sig_node.connect(auto_signal, self, "_transition", [transition_type])
	var busnum = AudioServer.get_bus_index(bus)
	if busnum == -1:
		var new_bus = AudioServer.add_bus(AudioServer.bus_count)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, bus)
		if bus != "Music":
			AudioServer.set_bus_send(AudioServer.get_bus_index(bus),"Music")
	for i in get_children():
		for o in i.get_children():
			o.set_bus(bus)

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
