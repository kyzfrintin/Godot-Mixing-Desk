tool
extends EditorPlugin

func _enter_tree():
	#music nodes
	add_custom_type("MixingDeskMusic", "Node", preload("music/mixing_desk_music.gd"), preload("music/mdm_icon.png"))
	add_custom_type("Song", "Node", preload("music/song.gd"), preload("music/song_icon.png"))
	add_custom_type("CoreContainer", "Node", preload("music/core_cont.gd"), preload("music/song_icon.png"))
	add_custom_type("RandomContainer", "Node", preload("music/ran_cont.gd"), preload("music/song_icon.png"))
	add_custom_type("SeqContainer", "Node", preload("music/seq_cont.gd"), preload("music/song_icon.png"))
	add_custom_type("ConcatContainer", "Node", preload("music/concat_cont.gd"), preload("music/song_icon.png"))
	
	#sound nodes
	add_custom_type("MixingDeskSound", "Node2D", preload("sound/mixing_desk_sound.gd"), preload("sound/mds_icon.png"))
	add_custom_type("Sound", "Node2D", preload("sound/sound.gd"), preload("sound/snd_icon.png"))
	

func _exit_tree():
	#music nodes
	remove_custom_type("MixingDeskMusic")
	remove_custom_type("Song")
	remove_custom_type("CoreContainer")
	remove_custom_type("RandomContainer")
	remove_custom_type("SeqContainer")
	remove_custom_type("ConcatContainer")
	
	#sound nodes
	remove_custom_type("MixingDeskSound")
	remove_custom_type("Sound")