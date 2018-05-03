extends Node2D

onready var icon = get_node("icon")

var layer_play

func _process(delta):
	layer_play = get_node("HSlider").value
	get_node("Time").text = str(MusicPlayer.time)
	get_node("Beat").text = str(MusicPlayer.beat)
	get_node("Bar").text = str(MusicPlayer.bar)
	get_node("slideval").text = str(get_node("HSlider").value)
	
func _play_pressed():
	MusicPlayer._play()

func _on_HSlider_value_changed(value):
	MusicPlayer._muteAboveLayer(value*1.0)
