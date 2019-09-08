extends Spatial

var dvols = []
var dpitches = []
var root
export var volume_range : float
export var pitch_range : float
export var sound_number : int

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
	
func play(num=0, ran=true):
	if num == 0:
		num = sound_number
	if num > 1:
		for i in range(0, num):
			var ransnd = _get_ransnd()
			_iplay(ransnd)
	else:
		var ransnd = _get_ransnd()
		_iplay(ransnd)
		
func _get_ransnd(ran=true):
	var children = get_child_count()
	var chance = randi() % children - 1
	var ransnd = get_child(chance)
	if ran:
		_randomise(ransnd)
	return ransnd
		
func _randomise(sound):
	var dvol = dvols[sound.get_index()]
	var dpitch = dpitches[sound.get_index()]
	var newvol = (dvol + _range(volume_range))
	var newpitch = (dpitch + _range(pitch_range))
	sound.unit_db = newvol
	sound.pitch_scale = newpitch
	
func _range(item : float) -> float:
	return rand_range(-item,item)