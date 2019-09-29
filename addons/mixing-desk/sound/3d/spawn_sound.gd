extends AudioStreamPlayer3D

func _ready():
	connect("finished", self, "finished")
	
func finished():
	queue_free() 