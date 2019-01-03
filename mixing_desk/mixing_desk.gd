tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("MixingDeskMusic", "Node", preload("music/mixing_desk_music.gd"), preload("music/mdm_icon.png"))
	add_custom_type("Song", "Node", preload("music/song.gd"), preload("music/song_icon.png"))
	add_custom_type("MixingDeskSound", "Node", preload("sound/mixing_desk_sound.gd"), preload("sound/mds_icon.png"))
	add_custom_type("Sound", "Node", preload("sound/sound.gd"), preload("sound/snd_icon.png"))
	

func _exit_tree():
	remove_custom_type("MixingDeskMusic")
	remove_custom_type("Song")
	remove_custom_type("MixingDeskSound")
	remove_custom_type("Sound")