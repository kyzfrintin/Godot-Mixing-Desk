extends Node

var dvols = []
var dpitches = []
var root
export var volume_range : float
export var pitch_range : float
export var sound_number : int

func _ready():
	for i in get_children():
		dvols.append(i.volume_db)
		dpitches.append(i.pitch_scale)
	root = Node.new()
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
		_randomise_pitch_and_vol(ransnd)
	return ransnd
		
func _randomise_pitch_and_vol(sound):
	var dvol = sound.get_parent().dvols[sound.get_index()]
	var dpitch = sound.get_parent().dpitches[sound.get_index()]
	var newvol = (dvol + rand_range(-volume_range,volume_range))
	var newpitch = (dpitch + rand_range(-pitch_range,pitch_range))
	sound.volume_db = newvol
	sound.pitch_scale = newpitch