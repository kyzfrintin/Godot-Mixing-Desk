extends Node2D

onready var mdm = get_node("MDM")

var colour : int = 0

func _ready():
	mdm._init_song(0)
	mdm._start_alone(0,0)
	
#func on_room_entered(body, i):
#	if body.name != 'player':
#		return
#	var areanum = i.get_index()
#	if colour != areanum:
#		print('changing to track ' + str(areanum))
#		mdm._queue_bar_transition(areanum)
#		colour = areanum
#		yield(mdm, "song_changed")