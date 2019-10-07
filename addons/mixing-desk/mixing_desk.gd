tool
extends EditorPlugin

func _enter_tree():
	#music nodes
	add_custom_type("MixingDeskMusic", "Node", preload("music/mixing_desk_music.gd"), preload("music/mdm_icon.png"))
	add_custom_type("Song", "Node", preload("music/song.gd"), preload("music/icons/song_icon.png"))
	add_custom_type("CoreContainer", "Node", preload("music/containers/core_cont.gd"), preload("music/icons/core_cont_icon.png"))
	add_custom_type("RandomContainer", "Node", preload("music/containers/ran_cont.gd"), preload("music/icons/ran_cont_icon.png"))
	add_custom_type("SeqContainer", "Node", preload("music/containers/seq_cont.gd"), preload("music/icons/seq_cont_icon.png"))
	add_custom_type("ConcatContainer", "Node", preload("music/containers/concat_cont.gd"), preload("music/icons/concat_cont_icon.png"))
	add_custom_type("RolloverContainer", "Node", preload("music/containers/rollover_cont.gd"), preload("music/icons/rollover_cont_icon.png"))
	add_custom_type("AutoFadeContainer", "Node", preload("music/containers/autofade_cont.gd"), preload("music/icons/autofade_cont_icon.png"))
	add_custom_type("AutoLayerContainer", "Node", preload("music/containers/autolayer_cont.gd"), preload("music/icons/autolayer_cont_icon.png"))
	
	#sound nodes - nonspatial
	add_custom_type("MultiSoundContainer", "Node", preload("sound/nonspatial/multi_sound.gd"), preload("sound/snd_icon.png"))
	add_custom_type("PolySoundContainer", "Node", preload("sound/nonspatial/polysound.gd"), preload("sound/snd_icon.png"))
	add_custom_type("RanSoundContainer", "Node", preload("sound/nonspatial/ran_cont.gd"), preload("sound/snd_icon.png"))
	add_custom_type("ScatterSoundContainer", "Node", preload("sound/nonspatial/scatter_cont.gd"), preload("sound/snd_icon.png"))
	add_custom_type("ConcatSoundContainer", "Node", preload("sound/nonspatial/concat_cont.gd"), preload("sound/snd_icon.png"))

	#sound nodes - 2d
	add_custom_type("MultiSoundContainer2D", "Node2D", preload("sound/2d/multi_sound.gd"), preload("sound/snd_icon.png"))
	add_custom_type("PolySoundContainer2D", "Node2D", preload("sound/2d/polysound.gd"), preload("sound/snd_icon.png"))
	add_custom_type("RanSoundContainer2D", "Node2D", preload("sound/2d/ran_cont.gd"), preload("sound/snd_icon.png"))
	add_custom_type("ScatterSoundContainer2D", "Node2D", preload("sound/2d/scatter_cont.gd"), preload("sound/snd_icon.png"))
	add_custom_type("ConcatSoundContainer2D", "Node2D", preload("sound/2d/concat_cont.gd"), preload("sound/snd_icon.png"))

	#sound nodes - 3d
	add_custom_type("MultiSoundContainer3D", "Spatial", preload("sound/3d/multi_sound.gd"), preload("sound/snd_icon.png"))
	add_custom_type("PolySoundContainer3D", "Spatial", preload("sound/3d/polysound.gd"), preload("sound/snd_icon.png"))
	add_custom_type("RanSoundContainer3D", "Spatial", preload("sound/3d/ran_cont.gd"), preload("sound/snd_icon.png"))
	add_custom_type("ScatterSoundContainer3D", "Spatial", preload("sound/3d/scatter_cont.gd"), preload("sound/snd_icon.png"))
	add_custom_type("ConcatSoundContainer3D", "Spatial", preload("sound/3d/concat_cont.gd"), preload("sound/snd_icon.png"))
	
func _exit_tree():
	#music nodes
	remove_custom_type("MixingDeskMusic")
	remove_custom_type("Song")
	remove_custom_type("CoreContainer")
	remove_custom_type("RandomContainer")
	remove_custom_type("SeqContainer")
	remove_custom_type("ConcatContainer")
	remove_custom_type("RolloverContainer")
	remove_custom_type("AutofadeContainer")
	
	#sound nodes - nonspatial
	remove_custom_type("MultiSoundContainer")
	remove_custom_type("PolysoundContainer")
	remove_custom_type("RanSoundContainer")
	remove_custom_type("ScatterSoundContainer")
	remove_custom_type("ConcatSoundContainer")

	#sound nodes - 2d
	remove_custom_type("MultiSoundContainer2D")
	remove_custom_type("PolysoundContainer2D")
	remove_custom_type("RanSoundContainer2D")
	remove_custom_type("ScatterSoundContainer2D")
	remove_custom_type("ConcatSoundContainer2D")

	#sound nodes - 3d
	remove_custom_type("MultiSoundContainer3D")
	remove_custom_type("PolysoundContainer3D")
	remove_custom_type("RanSoundContainer3D")
	remove_custom_type("ScatterSoundContainer3D")
	remove_custom_type("ConcatSoundContainer3D")
