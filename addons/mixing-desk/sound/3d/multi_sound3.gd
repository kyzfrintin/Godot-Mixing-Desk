extends Spatial

func play():
    for i in get_children():
        i.play()
