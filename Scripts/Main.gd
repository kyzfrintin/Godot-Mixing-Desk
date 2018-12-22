extends Node2D

onready var slider = get_node("Slider/HSlider")

func _process(delta):
	get_node("Time").text = "Time: " + str(MusicPlayer.time)
	get_node("Beat").text = "Beat: " + str(MusicPlayer.beat)
	get_node("Bar").text = "Bar: " + str(MusicPlayer.bar)
	get_node("Slider/slideval").text = str(slider.value)
	get_node("Slider/vols/vol1").text = str(MusicPlayer.players[0].get_volume_db())
	get_node("Slider/vols/vol2").text = str(MusicPlayer.players[1].get_volume_db())
	get_node("Slider/vols/vol3").text = str(MusicPlayer.players[2].get_volume_db())
	get_node("Slider/vols/vol4").text = str(MusicPlayer.players[3].get_volume_db())
	get_node("Slider/vols/vol5").text = str(MusicPlayer.players[4].get_volume_db())
	get_node("Slider/vols/vol6").text = str(MusicPlayer.players[5].get_volume_db())
	get_node("Slider/vols/vol7").text = str(MusicPlayer.players[6].get_volume_db())
	get_node("Slider/vols/vol8").text = str(MusicPlayer.players[7].get_volume_db())
	MusicPlayer._muteAboveLayer(slider.value)
	
	for thing in slider.get_children():
		thing.connect("player_entered", self, "player_entered_toggler_area")
	
func _play_pressed():
	MusicPlayer._startAlone(0)

func player_entered_toggler_area(name):
	slider.value = int(name)
#	slider.update()
	if(not MusicPlayer.playing):
		_play_pressed()
	MusicPlayer._muteAboveLayer(slider.value)

