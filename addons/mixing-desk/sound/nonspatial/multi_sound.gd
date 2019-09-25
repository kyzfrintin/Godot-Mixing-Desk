extends Node

export var autoplay : bool

func _ready():
	if autoplay:
		play()

func play():
    for i in get_children():
        i.play()

func stop():
	for i in get_children():
		i.stop()