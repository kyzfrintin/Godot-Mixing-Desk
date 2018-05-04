extends Node2D

onready var icon = get_node("icon")

func _process(delta):
	var slider = get_node("HSlider")
	get_node("Time").text = str(MusicPlayer.time)
	get_node("Beat").text = str(MusicPlayer.beat)
	get_node("Bar").text = str(MusicPlayer.bar)
	get_node("slideval").text = str(get_node("HSlider").value)
	get_node("vols/vol1").text = str(MusicPlayer.players[0].get_volume_db())
	get_node("vols/vol2").text = str(MusicPlayer.players[1].get_volume_db())
	get_node("vols/vol3").text = str(MusicPlayer.players[2].get_volume_db())
	get_node("vols/vol4").text = str(MusicPlayer.players[3].get_volume_db())
	get_node("vols/vol5").text = str(MusicPlayer.players[4].get_volume_db())
	get_node("vols/vol6").text = str(MusicPlayer.players[5].get_volume_db())
	get_node("vols/vol7").text = str(MusicPlayer.players[6].get_volume_db())
	get_node("vols/vol8").text = str(MusicPlayer.players[7].get_volume_db())
	MusicPlayer._muteAboveLayer(slider.value)
	
func _play_pressed():
	MusicPlayer._startAlone(0)