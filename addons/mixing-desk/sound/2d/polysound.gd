extends Node2D

var dvols = []
var dpitches = []
var root
export var volume_range : float
export var pitch_range : float

func _ready():
	for i in get_children():
		dvols.append(i.volume_db)
		dpitches.append(i.pitch_scale)
	root = Node2D.new()
	add_child(root)
	root.name = "root"

func _iplay(sound):
	var snd = sound.duplicate()
	root.add_child(snd)
	snd.play()
	#yield(snd, "finished")
	snd.connect("finished", self, "_snd_finished", [snd])
	#snd.queue_free()

func _snd_finished(snd):
	snd.disconnect("finished",self,"_snd_finished")
	snd.queue_free()
	
func play(ran=true):
	for i in get_children():
		if i.name == "root": return
		if ran:
			_randomise(i)
		_iplay(i)
		
func _randomise(sound):
	var dvol = dvols[sound.get_index()]
	var dpitch = dpitches[sound.get_index()]
	var newvol = (dvol + _range(volume_range))
	var newpitch = (dpitch + _range(pitch_range))
	sound.volume_db = newvol
	sound.pitch_scale = newpitch
	
func _range(item : float) -> float:
	return rand_range(-item,item)