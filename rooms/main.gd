extends Node2D

onready var mdm = get_node("MDM")

func _ready():
	mdm._init_song(0)
	mdm._play(0)
