extends Node2D

onready var mdm = get_node("MDM")

var colour : int = 0

func _ready():
	mdm._init_song(0)
	mdm._play(0)
	for i in $areas.get_children():
		i.connect('body_entered', self, 'on_room_entered', [i])
		
func on_room_entered(body, i):
	if body.name != 'player':
		return
	var areanum = i.get_index()
	if colour != areanum:
		print('changing to track ' + str(areanum))
		mdm._queue_bar_transition(areanum)
		colour = areanum