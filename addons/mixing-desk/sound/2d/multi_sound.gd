extends Node2D

func play():
    for i in get_children():
        i.play()
