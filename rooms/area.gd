extends Area2D

var balls : int = 0
var areanum : int

export(String) var prefix

onready var game = get_parent().get_parent()

func _ready():
	areanum = self.get_index()
	connect("body_entered",self,"on_room_entered")
	connect("body_exited",self,"on_room_exited")

func on_room_entered(body):
	if body.name.begins_with(prefix):
		balls += 1
		print('new ball! now ' + str(balls) + ' balls!')
		game.mdm._mute_above_layer(areanum,balls)
	if body.name == 'player':
		if game.colour != areanum:
			game.mdm._queue_bar_transition(areanum)
			game.colour = areanum
			game.mdm._mute_above_layer(areanum,balls)

func on_room_exited(body):
	if body.name.begins_with(prefix):
		balls -= 1
		game.mdm._mute_above_layer(areanum,balls)