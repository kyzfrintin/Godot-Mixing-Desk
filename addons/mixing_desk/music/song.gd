extends Node

var fading_out : bool = false
var fading_in : bool = false
export(int) var tempo
export(int) var bars
export(int) var beats_in_bar
export(int) var random_padding
export(float) var transition_beats
export(bool) var loop