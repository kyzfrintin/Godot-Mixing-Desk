extends AudioStreamPlayer

func setup():
	connect("finished", self, "finished")
	
func finished():
	queue_free() 