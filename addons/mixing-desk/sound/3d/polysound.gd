extends Spatial

var dvols = []
var dpitches = []
var root
export var volume_range : float
export var pitch_range : float

func _ready():
	for i in get_children():
		dvols.append(i.unit_db)
		dpitches.append(i.pitch_scale)
	root = Spatial.new()
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
			_randomise_pitch_and_vol(i)
		_iplay(i)
		
func _randomise_pitch_and_vol(sound):
	var dvol = sound.get_parent().dvols[sound.get_index()]
	var dpitch = sound.get_parent().dpitches[sound.get_index()]
	var newvol = (dvol + rand_range(-volume_range,volume_range))
	var newpitch = (dpitch + rand_range(-pitch_range,pitch_range))
	sound.unit_db = newvol
	sound.pitch_scale = newpitch