extends AudioStreamPlayer3D

func setup():
	connect("finished", self, "finished")
	
func finished():
	queue_free() 